import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

/// Chunky flat "sticker" container: thick ink border + hard offset shadow.
class Sticker extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color shadow;
  final double radius;
  final double dy;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;

  const Sticker({
    super.key,
    required this.child,
    this.color = AppTheme.surface,
    this.shadow = AppTheme.stickerShadowColor,
    this.radius = 24,
    this.dy = 5,
    this.padding,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: AppTheme.outline, width: AppTheme.borderWidth),
        boxShadow: [
          BoxShadow(color: shadow, offset: Offset(0, dy), blurRadius: 0),
        ],
      ),
      child: child,
    );
  }
}

/// A tappable [Sticker] with a fun press-down effect.
class StickerButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color shadow;
  final double radius;
  final double dy;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const StickerButton({
    super.key,
    required this.child,
    this.onTap,
    this.color = AppTheme.surface,
    this.shadow = AppTheme.stickerShadowColor,
    this.radius = 24,
    this.dy = 5,
    this.padding,
    this.margin,
  });

  @override
  State<StickerButton> createState() => _StickerButtonState();
}

class _StickerButtonState extends State<StickerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: AppTheme.outline, width: AppTheme.borderWidth),
            boxShadow: _pressed
                ? [BoxShadow(color: widget.shadow, offset: const Offset(0, 1), blurRadius: 0)]
                : [BoxShadow(color: widget.shadow, offset: Offset(0, widget.dy), blurRadius: 0)],
          ),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1,
            duration: const Duration(milliseconds: 110),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Map a stored color name to an [AppTheme] accent.
Color themeColor(String name) {
  switch (name) {
    case 'yellow':
      return AppTheme.primary;
    case 'mint':
      return AppTheme.mint;
    case 'coral':
      return AppTheme.coral;
    case 'pink':
      return AppTheme.pink;
    case 'periwinkle':
      return AppTheme.periwinkle;
    case 'sky':
      return AppTheme.sky;
    case 'lavender':
      return AppTheme.lavender;
    case 'lemon':
      return AppTheme.lemon;
    default:
      return AppTheme.mint;
  }
}

const List<ColorOption> walletColors = [
  ColorOption('yellow', AppTheme.primary),
  ColorOption('mint', AppTheme.mint),
  ColorOption('coral', AppTheme.coral),
  ColorOption('pink', AppTheme.pink),
  ColorOption('periwinkle', AppTheme.periwinkle),
  ColorOption('sky', AppTheme.sky),
  ColorOption('lavender', AppTheme.lavender),
  ColorOption('lemon', AppTheme.lemon),
];

class ColorOption {
  final String name;
  final Color color;
  const ColorOption(this.name, this.color);
}
