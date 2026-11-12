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
    final cardBase = isShared
        ? Color.lerp(base, AppTheme.surface, 0.45)!
        : base;
    final cardDark = isShared
        ? Color.lerp(dark, AppTheme.surface, 0.35)!
        : dark;
    final textColor = isShared ? AppTheme.inkFaint : AppTheme.ink;
    final softColor = isShared ? AppTheme.inkFaint : AppTheme.inkSoft;

    return StickerButton(
      onTap: onTap,
      color: cardBase,
      radius: 24,
      shadow: const Color(0xFFD9CFB6),
      padding: EdgeInsets.all(compact ? 18 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: compact ? 34 : 40,
                    height: compact ? 24 : 28,
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(8),
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
                          Icon(Icons.group_rounded,
                              color: Colors.white, size: 13),
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
                    GestureDetector(
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
                    )
                  else
                    Icon(
                      Icons.credit_card_rounded,
                      color: textColor,
                      size: compact ? 20 : 24,
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 20),
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
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: compact ? 14 : 20),
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
                    Text(
                      Money.format(card.balance),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textColor,
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
    );
  }
}