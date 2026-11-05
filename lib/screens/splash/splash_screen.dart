import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../themes/app_theme.dart';
import '../../services/storage/storage_service.dart';
import '../../widgets/vynl_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _logoSlideAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _glowPulseAnimation;

  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Logo descending animation from upward
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoSlideAnimation = Tween<double>(begin: -220.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    // Subtle gentle glow pulse
    _glowPulseAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeInOut,
      ),
    );

    // 2. Text fade and gentle slide
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textSlideAnimation = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start descending logo
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _logoController.forward();
      }
    });

    // Start text reveal shortly after logo starts settling
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        _textController.forward();
      }
    });

    // Seamless navigation transition after 2.8 seconds
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        if (StorageService.isOnboardingComplete()) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Modern slate / light-bluish background gradient
    final List<Color> bgColors = isDark
        ? [
            const Color(0xFF080D1A),
            const Color(0xFF0F172A),
            const Color(0xFF0B1120),
          ]
        : [
            const Color(0xFFF8FAFC),
            const Color(0xFFEEF5FB),
            const Color(0xFFE0EDF8),
          ];

    final primaryAccent = const Color(0xFF38BDF8); // Light Sky Blue

    return Scaffold(
      backgroundColor: bgColors.first,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.25,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient soft radial halo behind the logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoFadeAnimation.value,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryAccent.withValues(alpha: _glowPulseAnimation.value),
                            blurRadius: 90,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Center Logo Coming From Upward
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _logoSlideAnimation.value),
                          child: Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Opacity(
                              opacity: _logoFadeAnimation.value,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF131D33).withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.9),
                          border: Border.all(
                            color: primaryAccent.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryAccent.withValues(alpha: 0.25),
                              blurRadius: 30,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const VynlLogo(
                          size: 110,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App Name & "feel the vibe" tagline
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFadeAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, _textSlideAnimation.value),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: isDark
                                  ? [Colors.white, const Color(0xFF7DD3FC)]
                                  : [const Color(0xFF0F1E36), const Color(0xFF0284C7)],
                            ).createShader(bounds),
                            child: const Text(
                              'VYNL',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // The line under the logo requested by the user: "feel the vibe"
                          Text(
                            'feel the vibe',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 4.5,
                              color: isDark
                                  ? const Color(0xFF94A9C9)
                                  : const Color(0xFF476282),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom subtle indicator
              Positioned(
                bottom: 32,
                child: AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textFadeAnimation.value * 0.5,
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MUSIC FOR YOUR SOUL',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
