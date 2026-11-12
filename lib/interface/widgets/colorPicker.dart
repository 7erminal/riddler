import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

/// Row of chunky color swatches to pick a card / sub-wallet color.
class ColorPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const ColorPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final option in walletColors)
          GestureDetector(
            onTap: () => onChanged(option.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: option.name == selected ? AppTheme.ink : AppTheme.divider,
                  width: option.name == selected ? 4 : 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.stickerShadowColor,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: option.name == selected
                  ? const Icon(Icons.check_rounded, color: AppTheme.ink, size: 22)
                  : null,
            ),
          ),
      ],
    );
  }
}

/// A colorful chip that sits on top of a wallet tile.
class PercentChip extends StatelessWidget {
  final double percent;
  final Color color;

  const PercentChip({super.key, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.outline, width: 2.5),
      ),
      child: Text(
        Money.percent(percent),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppTheme.ink,
        ),
      ),
    );
  }
}
