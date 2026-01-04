// lib/features/auth/gx_awakening_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/gx_aura_widget.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/theme/app_theme.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'guest_mode_screen.dart';

class GXAwakeningScreen extends StatefulWidget {
  const GXAwakeningScreen({super.key});

  @override
  State<GXAwakeningScreen> createState() => _GXAwakeningScreenState();
}

class _GXAwakeningScreenState extends State<GXAwakeningScreen> 
    with SingleTickerProviderStateMixin {
  bool _showContent = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Delayed reveal
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showContent = true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Awakening sequence
              if (!_showContent)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing glow
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 200 + (_pulseController.value * 50),
                            height: 200 + (_pulseController.value * 50),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.auraStart.withOpacity(0.6),
                                  AppColors.auraEnd.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.auraStart.withOpacity(0.5),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 80),

                      // Reveal text
                      Text(
                        'This isn\'t an app.',
                        style: TextStyle(
                          color: AppTheme.ghostWhite.withOpacity(0.9),
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 16),

                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [AppColors.auraStart, AppColors.auraEnd],
                        ).createShader(bounds),
                        child: const Text(
                          'This is GX.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 800.ms, delay: 400.ms)
                          .scale(delay: 400.ms),
                    ],
                  ),
                ),

              // Main content
              if (_showContent)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Spacer(),

                      // GX Aura
                      const GXAuraWidget(
                        size: 160,
                        showParticles: true,
                        isAnimated: true,
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .scale(delay: 200.ms),

                      const SizedBox(height: 48),

                      // Tagline
                      Text(
                        'Your AI companion\nthat lives in your phone',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.ghostWhite.withOpacity(0.8),
                          fontSize: 18,
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                      const Spacer(),

                      // Action buttons
                      Column(
                        children: [
                          CustomButton(
                            text: 'Wake Up',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              );
                            },
                            width: double.infinity,
                            icon: Icons.flash_on,
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 600.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 16),

                          CustomButton(
                            text: 'I Have an Account',
                            isOutlined: true,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignInScreen(),
                                ),
                              );
                            },
                            width: double.infinity,
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 700.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 24),

                          // Guest mode
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const GuestModeScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: AppColors.auraEnd,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Try Guest Mode (10 min)',
                                  style: TextStyle(
                                    color: AppColors.auraEnd,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 800.ms),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}