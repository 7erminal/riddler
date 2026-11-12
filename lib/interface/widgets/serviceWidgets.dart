import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridlers/index.dart';

/// Top bar for service screens: back button, icon sticker, title + subtitle.
class ServiceHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const ServiceHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          StickerButton(
            onTap: () => Navigator.of(context).pop(),
            color: AppTheme.surface,
            radius: 14,
            dy: 3,
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.arrow_back_rounded, color: AppTheme.ink, size: 22),
          ),
          const SizedBox(width: 12),
          Sticker(
            color: color,
            radius: 18,
            dy: 3,
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: AppTheme.ink, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small label above form fields.
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
    );
  }
}

/// Cartoonish red banner for validation errors.
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3E4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.error, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: AppTheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Money input with a GH₵ prefix icon.
class ServiceAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const ServiceAmountField({super.key, required this.controller, this.hint = 'e.g. 50'});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(
        labelText: 'Amount',
        hintText: hint,
        prefixIcon: const Icon(Icons.payments_rounded),
      ),
    );
  }
}

/// Horizontal scroll of cards to pick the payment source.
class CardSelector extends StatelessWidget {
  final List<BankCard> cards;
  final String? selectedId;
  final ValueChanged<String> onChanged;
  final String emptyMessage;

  const CardSelector({
    super.key,
    required this.cards,
    required this.selectedId,
    required this.onChanged,
    this.emptyMessage = 'Attach a bank card in Accounts first.',
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Sticker(
        color: AppTheme.pink,
        radius: 16,
        dy: 2,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.credit_card_off_rounded, color: AppTheme.ink, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                emptyMessage,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final card = cards[i];
          final selected = card.id == selectedId;
          return GestureDetector(
            onTap: () => onChanged(card.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 190,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.outline, width: selected ? 3 : 2.5),
                boxShadow: const [
                  BoxShadow(color: AppTheme.stickerShadowColor, offset: Offset(0, 3), blurRadius: 0),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card_rounded, color: AppTheme.ink, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          Money.format(card.balance),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Segmented toggle between two destinations.
class DestToggle extends StatelessWidget {
  final String value;
  final List<({String key, String label, IconData icon})> options;
  final ValueChanged<String> onChanged;

  const DestToggle({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Sticker(
      color: AppTheme.surface,
      radius: 16,
      dy: 3,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          for (final option in options) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: value == option.key ? AppTheme.mint : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.outline, width: 2.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(option.icon, color: AppTheme.ink, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        option.label,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (option != options.last) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet: pick a wallet and optionally a pocket to pay from.
///
/// Returns a [WalletPaymentSource] on confirm, or `null` on cancel.
Future<WalletPaymentSource?> showWalletPaymentPicker(BuildContext context) {
  return showModalBottomSheet<WalletPaymentSource>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _WalletPaymentPickerSheet(),
  );
}

class _WalletPaymentPickerSheet extends StatefulWidget {
  const _WalletPaymentPickerSheet();

  @override
  State<_WalletPaymentPickerSheet> createState() => _WalletPaymentPickerPickerState();
}

class _WalletPaymentPickerPickerState extends State<_WalletPaymentPickerSheet> {
  late String _walletId;
  String? _subWalletId;

  @override
  void initState() {
    super.initState();
    final bloc = walletBloc;
    _walletId = bloc.wallets.isNotEmpty ? bloc.wallets.first.id : '';
  }

  Wallet? get _selectedWallet => walletBloc.walletById(_walletId);

  void _confirm() {
    final wallet = _selectedWallet;
    if (wallet == null) return;

    final sub = _subWalletId != null
        ? wallet.subWallets.where((s) => s.id == _subWalletId).firstOrNull
        : null;

    final source = WalletPaymentSource(
      walletId: wallet.id,
      walletName: wallet.name,
      subWalletId: sub?.id,
      subWalletTitle: sub?.title,
      available: sub != null ? sub.balance : wallet.mainBalance,
    );
    Navigator.of(context).pop(source);
  }

  @override
  Widget build(BuildContext context) {
    final wallets = walletBloc.wallets;
    final wallet = _selectedWallet;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.mint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.ink, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pay from wallet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose a wallet and pocket to pay from.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // ---- Wallet chips ----
            if (wallets.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No wallets yet.', style: TextStyle(fontSize: 13, color: AppTheme.inkSoft)),
              )
            else
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: wallets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final w = wallets[i];
                    final selected = w.id == _walletId;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _walletId = w.id;
                        _subWalletId = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: selected ? themeColor(w.color) : AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outline, width: selected ? 3 : 2.5),
                          boxShadow: const [
                            BoxShadow(color: AppTheme.stickerShadowColor, offset: Offset(0, 3), blurRadius: 0),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.savings_rounded, size: 18, color: AppTheme.ink),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(w.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                                Text(Money.formatCompact(w.totalBalance), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.inkSoft)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // ---- Pocket dropdown ----
            if (wallet != null && wallet.subWallets.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Pocket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.outline, width: 2.5),
                ),
                child: DropdownButton<String>(
                  value: _subWalletId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('Main (unallocated)'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Main (unallocated)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                    for (final s in wallet.subWallets)
                      DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.title} (${Money.format(s.balance)})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _subWalletId = v),
                ),
              ),
            ],

            const SizedBox(height: 20),
            StickerButton(
              onTap: wallets.isEmpty ? null : _confirm,
              color: AppTheme.primary,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: const Text('Confirm', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Combined payment source selector: toggle between card and wallet,
/// then show the appropriate picker.
class PaymentSourceSelector extends StatelessWidget {
  final List<BankCard> cards;
  final String? selectedCardId;
  final ValueChanged<String> onCardChanged;
  final WalletPaymentSource? walletSource;
  final ValueChanged<WalletPaymentSource?> onWalletChanged;
  final String sourceType; // 'card' | 'wallet'
  final ValueChanged<String> onSourceTypeChanged;

  const PaymentSourceSelector({
    super.key,
    required this.cards,
    required this.selectedCardId,
    required this.onCardChanged,
    required this.walletSource,
    required this.onWalletChanged,
    required this.sourceType,
    required this.onSourceTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- Toggle ----
        Sticker(
          color: AppTheme.surface,
          radius: 16,
          dy: 3,
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onSourceTypeChanged('card'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sourceType == 'card' ? AppTheme.mint : AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outline, width: 2.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card_rounded, color: AppTheme.ink, size: 20),
                        SizedBox(width: 6),
                        Text('Bank card', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: () => onSourceTypeChanged('wallet'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sourceType == 'wallet' ? AppTheme.mint : AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outline, width: 2.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.savings_rounded, color: AppTheme.ink, size: 20),
                        SizedBox(width: 6),
                        Text('Wallet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ---- Source display ----
        if (sourceType == 'card')
          CardSelector(
            cards: cards,
            selectedId: selectedCardId,
            onChanged: onCardChanged,
          )
        else
          GestureDetector(
            onTap: () async {
              final source = await showWalletPaymentPicker(context);
              if (source != null) onWalletChanged(source);
            },
            child: Sticker(
              color: walletSource != null ? AppTheme.lemon : AppTheme.surface,
              radius: 18,
              dy: 3,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppTheme.outline, width: 2.5),
                    ),
                    child: const Icon(Icons.savings_rounded, color: AppTheme.ink, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          walletSource?.label ?? 'Tap to choose wallet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: walletSource != null ? AppTheme.ink : AppTheme.inkSoft,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          walletSource != null
                              ? 'Available: ${Money.format(walletSource!.available)}'
                              : 'Pay from your wallet balance',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkFaint),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.ink),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Celebration sheet shown after a successful service action. [onDone] is
/// called when the user taps Done.
Future<void> showServiceSuccessSheet(
  BuildContext context, {
  required String title,
  required String message,
  String iconLabel = '🎉',
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.mint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.outline, width: 3),
            ),
            child: const Center(
              child: Text('🎉', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
          ),
          const SizedBox(height: 22),
          StickerButton(
            onTap: () => Navigator.of(context).pop(),
            color: AppTheme.primary,
            radius: 20,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
          ),
        ],
      ),
    ),
  );
}
