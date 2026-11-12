import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

/// A single sub-wallet row: colored icon, title + amount.
class SubWalletTile extends StatelessWidget {
  final SubWallet subWallet;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onWithdraw;

  const SubWalletTile({
    super.key,
    required this.subWallet,
    this.onTap,
    this.onDelete,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final base = themeColor(subWallet.color);

    return Sticker(
      color: base,
      radius: 22,
      dy: 4,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Color.lerp(base, Colors.white, 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.outline, width: 2.5),
            ),
            child: const Icon(
              Icons.savings_rounded,
              color: AppTheme.ink,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                subWallet.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (subWallet.allocation != null) ...[
            Sticker(
              color: AppTheme.surface,
              radius: 8,
              dy: 1,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              child: Text(
                'P${subWallet.priority}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.ink),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            Money.format(subWallet.balance),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(width: 4),
          if (onWithdraw != null)
            _IconAction(
              icon: Icons.north_east_rounded,
              color: base,
              tooltip: 'Withdraw',
              onTap: onWithdraw,
            ),
          if (onDelete != null)
            _IconAction(
              icon: Icons.delete_outline_rounded,
              color: AppTheme.surface,
              tooltip: 'Delete',
              onTap: onDelete,
            ),
        ],
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
