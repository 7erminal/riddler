import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridlers/index.dart';

/// Buy a data bundle. Pick a network, choose a bundle from its price list,
/// then confirm with a PIN. Pay from a card or wallet.
class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  String _network = 'MTN';
  DataBundle? _selected;
  String _sourceType = 'card';
  String? _cardId;
  WalletPaymentSource? _walletSource;
  String _error = '';
  bool _busy = false;

  List<DataBundle> get _bundles => dataBundles[_network] ?? [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cardId == null) {
      final cards = context.read<WalletBloc>().cards;
      if (cards.isNotEmpty) _cardId = cards.first.id;
    }
    if (_selected == null && _bundles.isNotEmpty) {
      _selected = _bundles.first;
    }
  }

  Future<void> _confirm() async {
    final bundle = _selected;
    if (bundle == null) {
      setState(() => _error = 'Pick a bundle first.');
      return;
    }

    if (_sourceType == 'card') {
      if (_cardId == null) {
        setState(() => _error = 'Pick the card to pay with.');
        return;
      }
      final card = context.read<WalletBloc>().cardById(_cardId!);
      if (card == null) return;
      if (card.balance < bundle.price) {
        setState(() => _error = 'Only ${Money.format(card.balance)} is available on that card.');
        return;
      }
    } else {
      if (_walletSource == null) {
        setState(() => _error = 'Pick the wallet to pay with.');
        return;
      }
      if (_walletSource!.available < bundle.price) {
        setState(() => _error = 'Only ${Money.format(_walletSource!.available)} is available.');
        return;
      }
    }

    final pin = await showPinPrompt(
      context,
      title: 'Confirm purchase',
      subtitle: '${bundle.provider} ${bundle.size} for ${Money.format(bundle.price)}',
      verify: (p) => authService.verifyPin(p),
    );
    if (pin == null || !mounted) return;

    setState(() => _busy = true);
    bool ok;
    if (_sourceType == 'card') {
      ok = await walletService.buyDataBundle(cardId: _cardId!, bundle: bundle);
    } else {
      ok = await walletService.buyDataBundleFromWallet(
        walletId: _walletSource!.walletId,
        subWalletId: _walletSource!.subWalletId,
        bundle: bundle,
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
      title: 'Bundle on its way!',
      message: '${bundle.provider} ${bundle.size} (${Money.format(bundle.price)}) is being loaded onto your line.',
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const ServiceHeader(
              title: 'Data bundle',
              subtitle: 'Pick a network, choose a bundle and pay from your card or wallet with your PIN.',
              icon: Icons.wifi_rounded,
              color: AppTheme.sky,
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
                    onTap: () => setState(() {
                      _network = n;
                      _selected = dataBundles[n]?.first;
                      _error = '';
                    }),
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
            const FieldLabel('Available bundles'),
            const SizedBox(height: 8),
            for (final bundle in _bundles)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selected = bundle;
                    _error = '';
                  }),
                  child: Sticker(
                    color: _selected?.id == bundle.id ? AppTheme.primary : AppTheme.surface,
                    radius: 18,
                    dy: 3,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppTheme.sky,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.outline, width: 2.5),
                          ),
                          child: const Icon(Icons.wifi_rounded, color: AppTheme.ink, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bundle.size,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                bundle.name,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Money.format(bundle.price),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
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
                      'Buy bundle',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
