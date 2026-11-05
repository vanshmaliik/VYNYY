import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/playback_provider.dart';

/// Navigation destination model for VYNL Curved Navigation Bar
class VynlNavDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const VynlNavDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// VYNL Fluid Scooped Navigation Bar Widget
/// Inspired by modern fluid curved capsule docks with a smooth circular dip
/// and an elevated floating active button.
class VynlCurvedNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<VynlNavDestination> destinations;
  final Color accentColor;

  const VynlCurvedNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.accentColor,
  });

  @override
  State<VynlCurvedNavigationBar> createState() => _VynlCurvedNavigationBarState();
}

class _VynlCurvedNavigationBarState extends State<VynlCurvedNavigationBar> {
  static const double _barHeight = 64.0;
  static const double _scoopWidth = 64.0;
  static const double _scoopDepth = 24.0;
  static const double _circleDiameter = 48.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double bottomMargin = bottomInset > 0 ? bottomInset + 6.0 : 16.0;

    // Deep blueish / midnight dock background
    final barBgColor = isDark
        ? const Color(0xFF13152C).withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.96);

    final borderColor = isDark
        ? const Color(0xFF282C55).withValues(alpha: 0.8)
        : Colors.black.withValues(alpha: 0.08);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth - 32.0;
        final itemWidth = totalWidth / widget.destinations.length;
        final activeX = (widget.selectedIndex + 0.5) * itemWidth;

        return Container(
          margin: EdgeInsets.only(left: 16, right: 16, bottom: bottomMargin),
          height: _barHeight + 14.0, // extra height for the floating active circle
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. The Scooped Capsule Background
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _barHeight,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: activeX),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedX, child) {
                    return CustomPaint(
                      painter: ScoopedBarPainter(
                        activeX: animatedX,
                        backgroundColor: barBgColor,
                        borderColor: borderColor,
                        borderRadius: 32.0,
                        scoopWidth: _scoopWidth,
                        scoopDepth: _scoopDepth,
                      ),
                    );
                  },
                ),
              ),

              // 2. Inactive Tab Buttons
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _barHeight,
                child: Row(
                  children: List.generate(widget.destinations.length, (index) {
                    final dest = widget.destinations[index];
                    final isSelected = widget.selectedIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (widget.selectedIndex != index) {
                            triggerHaptic(HapticFeedbackType.light);
                            widget.onDestinationSelected(index);
                          }
                        },
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isSelected ? 0.0 : 0.7, // Hidden when active because active circle covers it
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                dest.icon,
                                size: 22,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                dest.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // 3. Elevated Floating Active Circle
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: activeX),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                builder: (context, animatedX, child) {
                  return Positioned(
                    left: animatedX - (_circleDiameter / 2),
                    top: 0, // Sits partially elevated above the scoop
                    width: _circleDiameter,
                    height: _circleDiameter,
                    child: child!,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.45),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        widget.destinations[widget.selectedIndex].selectedIcon ??
                            widget.destinations[widget.selectedIndex].icon,
                        key: ValueKey(widget.selectedIndex),
                        size: 24,
                        color: _computeIconColor(widget.accentColor),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _computeIconColor(Color bg) {
    // Return black or white depending on accent luminance
    return bg.computeLuminance() > 0.4 ? Colors.black87 : Colors.white;
  }
}

/// Custom painter for the scooped capsule bar
class ScoopedBarPainter extends CustomPainter {
  final double activeX;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double scoopWidth;
  final double scoopDepth;

  ScoopedBarPainter({
    required this.activeX,
    required this.backgroundColor,
    required this.borderColor,
    this.borderRadius = 32.0,
    this.scoopWidth = 64.0,
    this.scoopDepth = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final r = borderRadius;
    final w = size.width;
    final h = size.height;

    final scoopLeft = (activeX - scoopWidth / 2).clamp(r, w - r - scoopWidth);
    final scoopRight = scoopLeft + scoopWidth;
    final scoopCenter = scoopLeft + scoopWidth / 2;

    final path = Path();
    path.moveTo(r, 0);

    // Left straight top edge
    path.lineTo(scoopLeft, 0);

    // Smooth concave dip into scoop
    path.cubicTo(
      scoopLeft + scoopWidth * 0.22, 0,
      scoopCenter - scoopWidth * 0.28, scoopDepth,
      scoopCenter, scoopDepth,
    );
    path.cubicTo(
      scoopCenter + scoopWidth * 0.28, scoopDepth,
      scoopRight - scoopWidth * 0.22, 0,
      scoopRight, 0,
    );

    // Right straight top edge
    path.lineTo(w - r, 0);

    // Top-right corner
    path.arcToPoint(Offset(w, r), radius: Radius.circular(r));
    // Right side
    path.lineTo(w, h - r);
    // Bottom-right corner
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    // Bottom edge
    path.lineTo(r, h);
    // Bottom-left corner
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
    // Left side
    path.lineTo(0, r);
    // Top-left corner
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    path.close();

    // Draw background shadow
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.25), 10, true);

    // Fill & Border
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant ScoopedBarPainter oldDelegate) {
    return oldDelegate.activeX != activeX ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor;
  }
}
