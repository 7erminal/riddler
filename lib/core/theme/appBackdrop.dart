import 'package:flutter/material.dart';
import 'package:ridlers/core/theme/appTheme.dart';

/// A pale blue-gray canvas with a barely-there gradient and tiny pastel accents.
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
    // Tiny, low-opacity accents stay near the edges so the brand colors in
    // the content can stand out against a quiet background.
    final accents = <({Offset center, double radius, Color color})>[
      (
        center: Offset(size.width * 0.985, size.height * 0.08),
        radius: 36,
        color: const Color(0x10C7E7FF),
      ),
      (
        center: Offset(size.width * 0.015, size.height * 0.54),
        radius: 30,
        color: const Color(0x0CFFD3E0),
      ),
      (
        center: Offset(size.width * 0.98, size.height * 0.90),
        radius: 32,
        color: const Color(0x0DCBFBF1),
      ),
    ];

    final fill = Paint()..style = PaintingStyle.fill;
    for (final accent in accents) {
      fill.color = accent.color;
      canvas.drawCircle(accent.center, accent.radius, fill);
    }

    _drawSparkle(
      canvas,
      Offset(size.width * 0.075, size.height * 0.14),
      5,
      const Color(0x18F6CF3F),
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.93, size.height * 0.44),
      4,
      const Color(0x168FE8D3),
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.10, size.height * 0.91),
      5,
      const Color(0x16FF9A76),
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
