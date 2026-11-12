import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ridlers/index.dart';

/// Transfer money from an attached card or wallet to another bank account
/// or to mobile money.
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amountCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  String _destType = 'bank';
  String _sourceType = 'card';
  String? _cardId;
  WalletPaymentSource? _walletSource;
  String _momoProvider = 'MTN';
  String _error = '';
  bool _busy = false;

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
    _bankCtrl.dispose();
    _accountCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount to transfer.');
      return;
    }

    // Validate source
    if (_sourceType == 'card') {
      if (_cardId == null) {
        setState(() => _error = 'Pick the card to send from.');
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
        setState(() => _error = 'Pick the wallet to send from.');
        return;
      }
      if (_walletSource!.available < amount) {
        setState(() => _error = 'Only ${Money.format(_walletSource!.available)} is available.');
        return;
      }
    }

    // Validate destination
    String? bankName;
    String? accountNumber;
    String? momoNumber;
    if (_destType == 'bank') {
      bankName = _bankCtrl.text.trim();
      accountNumber = _accountCtrl.text.replaceAll(' ', '');
      if (bankName.isEmpty || accountNumber.length < 4) {
        setState(() => _error = 'Enter the bank and the account number.');
        return;
      }
    } else {
      momoNumber = _numberCtrl.text.replaceAll(' ', '');
      if (momoNumber.length < 9) {
        setState(() => _error = 'Enter a valid mobile money number.');
        return;
      }
    }

    final pin = await showPinPrompt(
      context,
      title: 'Confirm transfer',
      subtitle: '${Money.format(amount)} to ${_destType == 'bank' ? (bankName ?? 'bank') : _momoProvider}',
      verify: (p) => authService.verifyPin(p),
    );
    if (pin == null || !mounted) return;

    setState(() => _busy = true);
    bool ok;
    if (_sourceType == 'card') {
      ok = await walletService.transferOut(
        sourceCardId: _cardId!,
        destType: _destType,
        amount: amount,
        bankName: bankName,
        accountNumber: accountNumber,
        momoProvider: _destType == 'momo' ? _momoProvider : null,
        momoNumber: momoNumber,
      );
    } else {
      ok = await walletService.transferOutFromWallet(
        walletId: _walletSource!.walletId,
        subWalletId: _walletSource!.subWalletId,
        destType: _destType,
        amount: amount,
        bankName: bankName,
        accountNumber: accountNumber,
        momoProvider: _destType == 'momo' ? _momoProvider : null,
        momoNumber: momoNumber,
      );
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      setState(() => _error = 'Transfer failed. Check the details and try again.');
      return;
    }

    await showServiceSuccessSheet(
      context,
      title: 'Transfer sent!',
      message: '${Money.format(amount)} is on its way to ${_destType == 'bank' ? (bankName ?? 'the bank') : '$_momoProvider • $momoNumber'}.',
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
                title: 'Transfer',
                subtitle: 'Send money from your bank account or wallet to another bank account or to mobile money.',
                icon: Icons.swap_horiz_rounded,
                color: AppTheme.mint,
              ),
              const SizedBox(height: 24),
              const FieldLabel('Send from'),
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
              const SizedBox(height: 20),
              const FieldLabel('Amount'),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'e.g. 100',
                  prefixIcon: Icon(Icons.payments_rounded),
                ),
              ),
              const SizedBox(height: 20),
              const FieldLabel('Transfer to'),
              const SizedBox(height: 8),
              DestToggle(
                value: _destType,
                options: const [
                  (key: 'bank', label: 'Bank account', icon: Icons.account_balance_rounded),
                  (key: 'momo', label: 'Mobile money', icon: Icons.phone_iphone_rounded),
                ],
                onChanged: (v) => setState(() => _destType = v),
              ),
              const SizedBox(height: 16),
              if (_destType == 'bank') ...[
                TextField(
                  controller: _bankCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Bank',
                    hintText: 'e.g. GCB',
                    prefixIcon: Icon(Icons.account_balance_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _accountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Account number',
                    hintText: 'e.g. 0221012345678',
                    prefixIcon: Icon(Icons.pin_rounded),
                  ),
                ),
              ] else ...[
                DropdownButtonFormField<String>(
                  initialValue: _momoProvider,
                  decoration: const InputDecoration(
                    labelText: 'Network',
                    prefixIcon: Icon(Icons.business_rounded),
                  ),
                  items: [
                    for (final p in momoProviders)
                      DropdownMenuItem(value: p, child: Text(p)),
                  ],
                  onChanged: (v) => setState(() => _momoProvider = v ?? 'MTN'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _numberCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Mobile money number',
                    hintText: 'e.g. 024 123 4567',
                    prefixIcon: Icon(Icons.phone_rounded),
                  ),
                ),
              ],
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
                        'Confirm & send',
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
