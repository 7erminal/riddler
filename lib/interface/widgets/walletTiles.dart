import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

/// A single sub-wallet card with a readable summary and expandable details.
class SubWalletTile extends StatefulWidget {
  final SubWallet subWallet;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onWithdraw;

  const SubWalletTile({
    super.key,
    required this.subWallet,
    this.onEdit,
    this.onDelete,
    this.onWithdraw,
  });

  @override
  State<SubWalletTile> createState() => _SubWalletTileState();
}

class _SubWalletTileState extends State<SubWalletTile> {
  bool _expanded = false;

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final pocket = widget.subWallet;
    final accent = themeColor(pocket.color);
    final accentWash = Color.lerp(accent, AppTheme.surface, 0.72)!;
    final purpose = pocket.purpose.trim();
    final purposePreview = purpose.isEmpty ? 'No purpose added yet' : purpose;

    return Sticker(
      color: AppTheme.surface,
      radius: 20,
      dy: 3,
      padding: const EdgeInsets.all(14),
      border: Border.all(color: AppTheme.outline, width: 2.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            hint: _expanded
                ? 'Tap to hide pocket details'
                : 'Tap to show the full purpose and split details',
            child: GestureDetector(
              onTap: _toggleExpanded,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Color.lerp(accent, AppTheme.surface, 0.48),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.outline, width: 2),
                        ),
                        child: const Icon(
                          Icons.savings_rounded,
                          color: AppTheme.ink,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pocket.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.ink,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.notes_rounded,
                                    size: 14,
                                    color: AppTheme.inkFaint,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      purposePreview,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.inkSoft,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: const Icon(
                            Icons.expand_more_rounded,
                            color: AppTheme.inkFaint,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BALANCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.inkFaint,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Money.format(pocket.balance),
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _ExpandedPocketDetails(
                    pocket: pocket,
                    purpose: purpose,
                    accentWash: accentWash,
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                    onWithdraw: widget.onWithdraw,
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}

class _ExpandedPocketDetails extends StatelessWidget {
  final SubWallet pocket;
  final String purpose;
  final Color accentWash;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onWithdraw;

  const _ExpandedPocketDetails({
    required this.pocket,
    required this.purpose,
    required this.accentWash,
    required this.onEdit,
    required this.onDelete,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final splitDescription = pocket.allocation == null
        ? '${Money.percent(pocket.percentage)} of every deposit goes into this pocket.'
        : 'Target ${Money.format(pocket.allocation!)} is filled by deposit priority.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 13),
        const Divider(height: 1, thickness: 1, color: AppTheme.divider),
        const SizedBox(height: 12),
        const Text(
          'POCKET PURPOSE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppTheme.inkFaint,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          purpose.isEmpty ? 'No purpose added yet.' : purpose,
          style: const TextStyle(
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PocketDetailChip(
              icon: pocket.allocation == null
                  ? Icons.pie_chart_rounded
                  : Icons.flag_rounded,
              label: splitDescription,
              color: accentWash,
            ),
            if (pocket.allocation != null)
              _PocketDetailChip(
                icon: Icons.low_priority_rounded,
                label: 'Priority ${pocket.priority}',
                color: accentWash,
              ),
          ],
        ),
        if (onEdit != null || onWithdraw != null || onDelete != null) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (onEdit != null)
                _PocketAction(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: accentWash,
                  onTap: onEdit,
                ),
              if (onWithdraw != null)
                _PocketAction(
                  icon: Icons.north_east_rounded,
                  label: 'Withdraw',
                  color: AppTheme.mint,
                  onTap: onWithdraw,
                ),
              if (onDelete != null)
                _DeletePocketAction(onTap: onDelete),
            ],
          ),
        ],
      ],
    );
  }
}

class _PocketDetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PocketDetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.inkSoft, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PocketAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _PocketAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StickerButton(
      onTap: onTap,
      color: color,
      radius: 13,
      dy: 2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.ink, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletePocketAction extends StatelessWidget {
  final VoidCallback? onTap;

  const _DeletePocketAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return StickerButton(
      onTap: onTap,
      color: AppTheme.pink,
      radius: 13,
      dy: 2,
      padding: const EdgeInsets.all(9),
      child: const Tooltip(
        message: 'Delete pocket',
        child: Icon(Icons.delete_outline_rounded, color: AppTheme.ink, size: 18),
      ),
    );
  }
}

/// A small chunky round icon button used on tiles.
class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: StickerButton(
        onTap: onTap,
        color: color,
        radius: 10,
        dy: 2,
        padding: const EdgeInsets.all(4),
        child: Tooltip(message: tooltip, child: Icon(icon, color: AppTheme.ink, size: 13)),
      ),
    );
  }
}

/// Horizontal chips to switch between the user's wallets.
class WalletSelector extends StatelessWidget {
  final Wallet active;
  final List<Wallet> wallets;
  final ValueChanged<String> onSelected;
  final VoidCallback? onAdd;

  const WalletSelector({
    super.key,
    required this.active,
    required this.wallets,
    required this.onSelected,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: wallets.length + (onAdd != null ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          if (onAdd != null && i == wallets.length) {
            return StickerButton(
              onTap: onAdd,
              color: AppTheme.surface,
              radius: 18,
              dy: 3,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, color: AppTheme.ink, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'New wallet',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink),
                  ),
                ],
              ),
            );
          }
          final w = wallets[i];
          final selected = w.id == active.id;
          return GestureDetector(
            onTap: () => onSelected(w.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? themeColor(w.color) : AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.outline, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.stickerShadowColor,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.savings_rounded,
                    size: 18,
                    color: AppTheme.ink,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                      Text(
                        Money.formatCompact(w.totalBalance),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.inkSoft,
                        ),
                      ),
                    ],
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

/// The wallet's own (main) pocket, shown separately from sub-wallets.
class MainWalletTile extends StatelessWidget {
  final double amount;
  final VoidCallback? onTap;
  final VoidCallback? onWithdraw;

  const MainWalletTile({
    super.key,
    required this.amount,
    this.onTap,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return StickerButton(
      onTap: onTap,
      color: AppTheme.primary,
      radius: 22,
      dy: 4,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.outline, width: 2.5),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppTheme.ink,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Main Wallet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Money.format(amount),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          if (onWithdraw != null)
            _IconAction(
              icon: Icons.north_east_rounded,
              color: AppTheme.primaryDark,
              tooltip: 'Withdraw',
              onTap: onWithdraw,
            ),
        ],
      ),
    );
  }
}

/// Horizontal segmented bar visualising how the wallet splits deposits.
class AllocationBar extends StatelessWidget {
  final Wallet wallet;

  const AllocationBar({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    if (wallet.splitMode == 'figures') {
      final targets = wallet.subWallets
          .where((w) => (w.allocation ?? 0) > 0)
          .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
      if (targets.isEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 26,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              border: Border.all(color: AppTheme.outline, width: 2.5),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 26,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            border: Border.all(color: AppTheme.outline, width: 2.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              for (final w in targets)
                Expanded(
                  flex: (w.allocation! * 100).round().clamp(1, 10000),
                  child: ColoredBox(
                    color: themeColor(w.color),
                    child: const SizedBox.expand(),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 26,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          border: Border.all(color: AppTheme.outline, width: 2.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (wallet.remainingPercent > 0)
              Expanded(
                flex: (wallet.remainingPercent * 100).round(),
                child: ColoredBox(
                  color: AppTheme.primaryDark,
                  child: const SizedBox.expand(),
                ),
              ),
            for (final w in wallet.subWallets)
              if (w.percentage > 0)
                Expanded(
                  flex: (w.percentage * 100).round(),
                  child: ColoredBox(
                    color: themeColor(w.color),
                    child: const SizedBox.expand(),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
