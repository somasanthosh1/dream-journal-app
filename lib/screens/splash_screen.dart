import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbitCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.elasticOut),
    );
    _fadeCtrl.forward();

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg0,
      body: Stack(
        children: [
          // Starfield background
          ...List.generate(60, (i) {
            final rng = math.Random(i * 7 + 3);
            return Positioned(
              left: rng.nextDouble() * MediaQuery.of(context).size.width,
              top: rng.nextDouble() * MediaQuery.of(context).size.height,
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Opacity(
                  opacity: (0.2 + rng.nextDouble() * 0.6) * _pulse.value,
                  child: Container(
                    width: rng.nextDouble() * 3 + 1,
                    height: rng.nextDouble() * 3 + 1,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Aurora glow blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.auroraViolet.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.auroraTeal.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Orbiting rings + moon icon
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer orbit ring
                          AnimatedBuilder(
                            animation: _orbitCtrl,
                            builder: (_, __) => Transform.rotate(
                              angle: _orbitCtrl.value * 2 * math.pi,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.auroraViolet.withOpacity(0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.auroraPink,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.auroraPink.withOpacity(0.8),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Inner orbit ring
                          AnimatedBuilder(
                            animation: _orbitCtrl,
                            builder: (_, __) => Transform.rotate(
                              angle: -_orbitCtrl.value * 2 * math.pi * 1.5,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.auroraTeal.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.auroraTeal,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.auroraTeal.withOpacity(0.8),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Core moon
                          AnimatedBuilder(
                            animation: _pulse,
                            builder: (_, __) => Transform.scale(
                              scale: _pulse.value,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color(0xFFB09FFF),
                                      Color(0xFF6B4FF7),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.auroraViolet.withOpacity(0.6),
                                      blurRadius: 28,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.nightlight_round,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFE0D7FF),
                          Color(0xFF9B8FC8),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'Dream Journal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'your nocturnal universe',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 64),
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        backgroundColor: AppTheme.bg3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.auroraViolet.withOpacity(0.8),
                        ),
                        minHeight: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
