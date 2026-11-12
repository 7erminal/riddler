import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ridlers/index.dart';

/// Buy airtime for any number on the supported networks, paid from a card
/// or wallet. A PIN is required to complete the purchase.
class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  final _amountCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  String _network = 'MTN';
  String _sourceType = 'card';
  String? _cardId;
  WalletPaymentSource? _walletSource;
  String _error = '';
  bool _busy = false;

  static const _quickAmounts = [5.0, 10.0, 20.0, 50.0];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cardId == null) {
      final cards = context.read<WalletBloc>().cards;
      if (cards.isNotEmpty) _cardId = cards.first.id;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final amount = double.tryParse(_amountCtrl.text);
    final number = _numberCtrl.text.replaceAll(' ', '');
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter the amount of airtime to buy.');
      return;
    }
    if (number.length < 9) {
      setState(() => _error = 'Enter a valid phone number.');
      return;
    }

    // Validate source
    if (_sourceType == 'card') {
      if (_cardId == null) {
        setState(() => _error = 'Pick the card to pay with.');
        return;
      }
      final card = context.read<WalletBloc>().cardById(_cardId!);
      if (card == null) return;
      if (card.balance < amount) {
        setState(() => _error = 'Only ${Money.format(card.balance)} is available on that card.');
        return;
      }
    } else {
      if (_walletSource == null) {
        setState(() => _error = 'Pick the wallet to pay with.');
        return;
      }
      if (_walletSource!.available < amount) {
        setState(() => _error = 'Only ${Money.format(_walletSource!.available)} is available.');
        return;
      }
    }

    final pin = await showPinPrompt(
      context,
      title: 'Buy airtime',
      subtitle: '$_network airtime of ${Money.format(amount)} for $number',
      verify: (p) => authService.verifyPin(p),
    );
    if (pin == null || !mounted) return;

    setState(() => _busy = true);
    bool ok;
    if (_sourceType == 'card') {
      ok = await walletService.buyAirtime(
        cardId: _cardId!,
        network: _network,
        number: number,
        amount: amount,
      );
    } else {
      ok = await walletService.buyAirtimeFromWallet(
        walletId: _walletSource!.walletId,
        subWalletId: _walletSource!.subWalletId,
        network: _network,
        number: number,
        amount: amount,
      );
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      setState(() => _error = 'Purchase failed. Check the details and try again.');
      return;
    }

    await showServiceSuccessSheet(
      context,
      title: 'Airtime bought!',
      message: '${Money.format(amount)} of $_network airtime was sent to $number.',
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const ServiceHeader(
                title: 'Buy airtime',
                subtitle: 'Top up any number. Pay from your bank card or wallet, secured with your PIN.',
                icon: Icons.smartphone_rounded,
                color: AppTheme.pink,
              ),
              const SizedBox(height: 24),
              const FieldLabel('Network'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final n in serviceNetworks)
                    GestureDetector(
                      onTap: () => setState(() => _network = n),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: _network == n ? AppTheme.primary : AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outline, width: _network == n ? 3 : 2.5),
                          boxShadow: const [
                            BoxShadow(color: AppTheme.stickerShadowColor, offset: Offset(0, 3), blurRadius: 0),
                          ],
                        ),
                        child: Text(
                          n,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const FieldLabel('Number'),
              const SizedBox(height: 8),
              TextField(
                controller: _numberCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: 'e.g. 024 123 4567',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
              ),
              const SizedBox(height: 20),
              const FieldLabel('Amount'),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'e.g. 20',
                  prefixIcon: Icon(Icons.payments_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final a in _quickAmounts)
                    GestureDetector(
                      onTap: () => _amountCtrl.text = a.toStringAsFixed(0),
                      child: Sticker(
                        color: AppTheme.lavender,
                        radius: 12,
                        dy: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          Money.formatCompact(a),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const FieldLabel('Pay with'),
              const SizedBox(height: 8),
              PaymentSourceSelector(
                cards: bloc.cards,
                selectedCardId: _cardId,
                onCardChanged: (id) => setState(() => _cardId = id),
                walletSource: _walletSource,
                onWalletChanged: (s) => setState(() => _walletSource = s),
                sourceType: _sourceType,
                onSourceTypeChanged: (v) => setState(() => _sourceType = v),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 14),
                ErrorBanner(message: _error),
              ],
              const SizedBox(height: 24),
              StickerButton(
                onTap: _busy ? null : _confirm,
                color: AppTheme.primary,
                radius: 20,
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: _busy
                    ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(AppTheme.ink),
                        ),
                      )
                    : const Text(
                        'Buy airtime',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
