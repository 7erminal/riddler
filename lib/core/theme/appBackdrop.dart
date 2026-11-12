import 'package:flutter/material.dart';
import 'package:ridlers/core/theme/appTheme.dart';

/// A soft sky-blue canvas with a few oversized pastel doodles.
///
/// Keeping the decoration behind the navigator gives every screen a shared
/// brand surface without affecting scrolling, hit testing, or route changes.
class AppBackdrop extends StatelessWidget {
  final Widget child;

  const AppBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.background, AppTheme.backgroundShade],
            ),
          ),
          child: SizedBox.expand(),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _PaperDoodlePainter()),
          ),
        ),
        child,
      ],
    );
  }
}

class _PaperDoodlePainter extends CustomPainter {
  const _PaperDoodlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Soft cloud-like circles and tiny sticker sparkles add color without
    // lowering contrast or competing with the content.
    final accents = <({Offset center, double radius, Color color})>[
      (
        center: Offset(size.width * 0.99, size.height * 0.12),
        radius: 62,
        color: const Color(0x2BFFFFFF),
      ),
      (
        center: Offset(size.width * 0.01, size.height * 0.56),
        radius: 42,
        color: const Color(0x1FFFD3E0),
      ),
      (
        center: Offset(size.width * 0.96, size.height * 0.78),
        radius: 48,
        color: const Color(0x1CCBFBF1),
      ),
    ];

    final fill = Paint()..style = PaintingStyle.fill;
    for (final accent in accents) {
      fill.color = accent.color;
      canvas.drawCircle(accent.center, accent.radius, fill);
    }

    _drawSparkle(
      canvas,
      Offset(size.width * 0.09, size.height * 0.19),
      8,
      const Color(0x3AF6CF3F),
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.91, size.height * 0.43),
      6,
      const Color(0x3A8FE8D3),
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.12, size.height * 0.87),
      7,
      const Color(0x35FF9A76),
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
    canvas.drawCircle(center, 2.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PaperDoodlePainter oldDelegate) => false;
}
