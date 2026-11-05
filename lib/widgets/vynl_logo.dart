import 'package:flutter/material.dart';

/// VYNL App Logo Widget
/// Renders the sleek white geometric origami V logo.
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
        // Fallback custom vector painter of the origami geometric V symbol
        return CustomPaint(
          size: Size(size, size),
          painter: VynlGeometricPainter(
            color: color ?? Colors.white,
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
          color: const Color(0xFF10192E),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
              blurRadius: 14,
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

/// Custom vector painter that renders the geometric origami V logo
class VynlGeometricPainter extends CustomPainter {
  final Color color;

  const VynlGeometricPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Left folded wing
    final leftPath = Path()
      ..moveTo(w * 0.14, h * 0.18)
      ..lineTo(w * 0.48, h * 0.18)
      ..lineTo(w * 0.34, h * 0.44)
      ..lineTo(w * 0.22, h * 0.26)
      ..lineTo(w * 0.50, h * 0.86)
      ..lineTo(w * 0.14, h * 0.18)
      ..close();
    canvas.drawPath(leftPath, paint);

    // Right folded wing
    final rightPath = Path()
      ..moveTo(w * 0.86, h * 0.18)
      ..lineTo(w * 0.52, h * 0.18)
      ..lineTo(w * 0.38, h * 0.46)
      ..lineTo(w * 0.50, h * 0.70)
      ..lineTo(w * 0.72, h * 0.26)
      ..lineTo(w * 0.58, h * 0.54)
      ..lineTo(w * 0.86, h * 0.18)
      ..close();
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(covariant VynlGeometricPainter oldDelegate) => oldDelegate.color != color;
}
