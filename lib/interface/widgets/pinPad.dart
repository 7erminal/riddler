import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

/// Cartoonish numeric keypad used for PIN entry.
class PinPad extends StatelessWidget {
  final ValueChanged<String> onTap;
  final VoidCallback onBackspace;

  const PinPad({
    super.key,
    required this.onTap,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 3; row++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var col = 0; col < 3; col++)
                _PinKey(
                  label: keys[row * 3 + col],
                  onTap: () => onTap(keys[row * 3 + col]),
                ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 72),
            _PinKey(
              label: '0',
              onTap: () => onTap('0'),
            ),
            _PinKey(
              label: '⌫',
              onTap: onBackspace,
              showIcon: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool showIcon;

  const _PinKey({
    required this.label,
    required this.onTap,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return StickerButton(
      onTap: onTap,
      color: AppTheme.surface,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: SizedBox(
        width: 24,
        child: Center(
          child: showIcon
              ? const Icon(Icons.backspace_outlined, color: AppTheme.ink, size: 24)
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Dots showing PIN progress.
class PinDots extends StatelessWidget {
  final int length;
  final int total;

  const PinDots({super.key, required this.length, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: i < length ? 34 : 22,
            height: 22,
            decoration: BoxDecoration(
              color: i < length ? AppTheme.primary : AppTheme.surface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppTheme.outline, width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD9CFB6),
                  offset: Offset(0, i < length ? 4 : 2),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
          if (i != total - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}
