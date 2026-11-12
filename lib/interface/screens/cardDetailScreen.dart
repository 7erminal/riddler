import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ridlers/index.dart';

/// Full-screen view of a single bank card.
///
/// Owned cards get Withdraw / Share / manage actions. Shared cards (cards
/// another customer shared with you) get a withdraw flow that requires the
/// owner's approval, and a greyed-out deposit button (coming soon).
class CardDetailScreen extends StatelessWidget {
  final BankCard card;

  const CardDetailScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();
    final ownerPhone = _ownerPhoneOf(context, bloc);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                StickerButton(
                  onTap: () => Navigator.of(context).pop(),
                  color: AppTheme.surface,
                  radius: 14,
                  dy: 2,
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.chevron_left_rounded, color: AppTheme.ink, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CARD DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.inkFaint,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.isShared ? 'Shared card' : card.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            BankCardView(
              card: card,
              isShared: card.isShared,
              showShareIcon: !card.isShared,
              onShare: () => showShareCardSheet(context, card),
            ),
            const SizedBox(height: 14),
            if (card.isShared) ...[
              Sticker(
                color: AppTheme.lavender,
                radius: 16,
                dy: 3,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.group_rounded, color: AppTheme.ink, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ownerPhone.isEmpty
                            ? 'Shared account — withdrawals need the owner\'s approval.'
                            : 'Shared by $ownerPhone — withdrawals need their approval.',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Sticker(
                color: AppTheme.surface,
                radius: 16,
                dy: 3,
                padding: const EdgeInsets.all(14),
                child: Text(
                  'Balance is tracked on this device. Pull money into your wallet or share this card with another customer.',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                ),
              ),
            const SizedBox(height: 22),

            if (card.isShared) ...[
              _ActionRow(
                icon: Icons.north_east_rounded,
                label: 'Withdraw to wallet',
                subtitle: 'Sends a request to the owner for approval',
                color: AppTheme.periwinkle,
                onTap: () => showCardWithdrawSheet(context, card: card, shared: true),
              ),
              const SizedBox(height: 12),
              _ActionRow(
                icon: Icons.add_card_rounded,
                label: 'Deposit to this account',
                subtitle: 'Coming soon',
                color: AppTheme.inkFaint,
                onTap: null,
              ),
            ] else ...[
              _ActionRow(
                icon: Icons.north_east_rounded,
                label: 'Withdraw to wallet',
                subtitle: 'Moves money to your wallet now',
                color: AppTheme.coral,
                onTap: () => showCardWithdrawSheet(context, card: card, shared: false),
              ),
              const SizedBox(height: 12),
              _ActionRow(
                icon: Icons.share_rounded,
                label: 'Share this card',
                subtitle: 'Give another customer access (approved by you)',
                color: AppTheme.primary,
                onTap: () => showShareCardSheet(context, card),
              ),
              const SizedBox(height: 12),
              _ActionRow(
                icon: Icons.refresh_rounded,
                label: 'Update reported balance',
                subtitle: 'Set what your bank reports',
                color: AppTheme.ink,
                onTap: () => _updateBalance(context),
              ),
              const SizedBox(height: 12),
              _ActionRow(
                icon: Icons.delete_outline_rounded,
                label: 'Remove card',
                color: AppTheme.error,
                onTap: () => _removeCard(context),
              ),
            ],

            const SizedBox(height: 24),
            const Text(
              'Shared withdrawals always land in the withdrawing customer\'s wallet.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkFaint),
            ),
          ],
        ),
      ),
    );
  }

  String _ownerPhoneOf(BuildContext context, WalletBloc bloc) {
    for (final share in bloc.acceptedSharesWithMe) {
      if (share.cardId == card.id) return share.ownerPhone;
    }
    return '';
  }

  Future<void> _updateBalance(BuildContext context) async {
    final controller = TextEditingController(text: card.balance.toStringAsFixed(2));
    final value = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Update balance',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink),
            ),
            const SizedBox(height: 4),
            Text(
              'Set what ${card.bankName} reports as the current balance.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: const InputDecoration(
                labelText: 'New balance',
                prefixIcon: Icon(Icons.payments_rounded),
              ),
            ),
            const SizedBox(height: 16),
            StickerButton(
              onTap: () {
                final v = double.tryParse(controller.text);
                if (v != null && v >= 0) Navigator.of(context).pop(v);
              },
              color: AppTheme.primary,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ),
          ],
        ),
      ),
    );
    if (value != null && context.mounted) {
      await walletService.updateCardBalance(card.id, value);
    }
  }

  Future<void> _removeCard(BuildContext context) async {
    final ok = await confirmDelete(
      context,
      title: 'Remove ${card.nickname}?',
      message: 'You can re-attach it later. Active shares stop working.',
      confirmLabel: 'Remove',
    );
    if (!ok || !context.mounted) return;
    await walletService.deleteCard(card.id);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${card.nickname} removed')),
      );
    }
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = StickerButton(
      onTap: onTap,
      color: onTap == null ? AppTheme.surface : AppTheme.surface,
      radius: 18,
      dy: 3,
      padding: const EdgeInsets.all(14),
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: AppTheme.inkFaint),
          ],
        ),
      ),
    );
    return box;
  }
}