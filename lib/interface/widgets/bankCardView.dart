import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

/// A chunky, cartoonish bank card visual.
///
/// Owned cards can show a share icon (via [showShareIcon] + [onShare]) that
/// links into the shared-card-access flow. Shared cards ([isShared]) render
/// muted with a SHARED badge so they're easy to tell apart from owned cards.
class BankCardView extends StatelessWidget {
  final BankCard card;
  final VoidCallback? onTap;
  final bool compact;
  final bool showShareIcon;
  final VoidCallback? onShare;
  final bool isShared;

  const BankCardView({
    super.key,
    required this.card,
    this.onTap,
    this.compact = false,
    this.showShareIcon = false,
    this.onShare,
    this.isShared = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = themeColor(card.color);
    final dark = Color.lerp(base, AppTheme.ink, 0.35)!;
    final cardBase = isShared ? Color.lerp(base, AppTheme.surface, 0.45)! : base;
    final cardDark = isShared ? Color.lerp(dark, AppTheme.surface, 0.35)! : dark;
    final textColor = isShared ? AppTheme.inkFaint : AppTheme.ink;
    final softColor = isShared ? AppTheme.inkFaint : AppTheme.inkSoft;
    final chipLine = Color.lerp(cardDark, AppTheme.ink, 0.22)!;
    final chipWidth = compact ? 34.0 : 40.0;
    final chipHeight = compact ? 24.0 : 28.0;

    return StickerButton(
      onTap: onTap,
      color: cardBase,
      radius: 24,
      shadow: AppTheme.stickerShadowColor,
      padding: EdgeInsets.all(compact ? 18 : 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Soft, oversized card-print shapes add depth without competing
            // with the account details.
            Positioned(
              right: compact ? -34 : -44,
              top: compact ? -42 : -54,
              child: Container(
                width: compact ? 104 : 132,
                height: compact ? 104 : 132,
                decoration: BoxDecoration(
                  color: Color.lerp(cardBase, AppTheme.surface, 0.42),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: compact ? 14 : 22,
              bottom: compact ? 8 : 10,
              child: Container(
                width: compact ? 62 : 82,
                height: compact ? 62 : 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color.lerp(cardBase, AppTheme.ink, 0.08)!,
                    width: 2,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: chipWidth,
                      height: chipHeight,
                      decoration: BoxDecoration(
                        color: Color.lerp(cardDark, AppTheme.primaryDark, 0.28),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: chipLine, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Positioned(
                              left: chipWidth / 2 - 0.75,
                              top: 0,
                              bottom: 0,
                              child: Container(width: 1.5, color: chipLine),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: chipHeight / 2 - 0.75,
                              child: Container(height: 1.5, color: chipLine),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        card.bankName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 15 : 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (isShared)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.ink,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.group_rounded, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'SHARED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (showShareIcon && onShare != null)
                      Tooltip(
                        message: 'Share card',
                        child: GestureDetector(
                          onTap: onShare,
                          child: Container(
                            width: compact ? 30 : 34,
                            height: compact ? 30 : 34,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.outline, width: 2.5),
                            ),
                            child: Icon(
                              Icons.share_rounded,
                              color: AppTheme.inkSoft,
                              size: compact ? 15 : 17,
                            ),
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.credit_card_rounded,
                        color: textColor,
                        size: compact ? 20 : 24,
                      ),
                  ],
                ),
                SizedBox(height: compact ? 12 : 20),
                Text(
                  card.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: softColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.maskedNumber,
                  style: TextStyle(
                    fontSize: compact ? 16 : 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: compact ? 10 : 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: softColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Money.format(card.balance),
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: compact ? 20 : 22,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (card.isPrimary && !isShared)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.ink,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'MAIN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
