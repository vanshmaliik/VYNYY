import 'package:flutter/material.dart';

/// VYNL App Logo Widget
/// Renders the geometric neon V logo.
class VynlLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool withBackground;
  final double borderRadius;

  const VynlLogo({
    super.key,
    this.size = 48.0,
    this.color,
    this.withBackground = false,
    this.borderRadius = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoWidget = Image.asset(
      'assets/images/vynl_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback custom vector painter of the geometric V symbol
        return CustomPaint(
          size: Size(size, size),
          painter: VynlGeometricPainter(
            color: color ?? const Color(0xFFB8E11B),
          ),
        );
      },
    );

    if (withBackground) {
      return Container(
        width: size + 16,
        height: size + 16,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E224A),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: const Color(0xFF38407A).withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB8E11B).withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: logoWidget),
      );
    }

    return logoWidget;
  }
}

/// Custom vector painter that renders the geometric V logo
class VynlGeometricPainter extends CustomPainter {
  final Color color;

  const VynlGeometricPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.085;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Bottom apex
    final apex = Offset(w * 0.5, h * 0.88);

    // Center vertical stem
    canvas.drawLine(Offset(w * 0.5, h * 0.55), apex, paint);

    // Main V chevron left and right
    final pathMainV = Path()
      ..moveTo(w * 0.32, h * 0.22)
      ..lineTo(w * 0.32, h * 0.35)
      ..lineTo(apex.dx, apex.dy)
      ..lineTo(w * 0.68, h * 0.35)
      ..lineTo(w * 0.68, h * 0.22);
    canvas.drawPath(pathMainV, paint);

    // Outer branching prongs
    final pathOuterLeft = Path()
      ..moveTo(w * 0.18, h * 0.26)
      ..lineTo(w * 0.18, h * 0.38)
      ..lineTo(w * 0.45, h * 0.78);
    canvas.drawPath(pathOuterLeft, paint);

    final pathOuterRight = Path()
      ..moveTo(w * 0.82, h * 0.26)
      ..lineTo(w * 0.82, h * 0.38)
      ..lineTo(w * 0.55, h * 0.78);
    canvas.drawPath(pathOuterRight, paint);
  }

  @override
  bool shouldRepaint(covariant VynlGeometricPainter oldDelegate) => oldDelegate.color != color;
}
