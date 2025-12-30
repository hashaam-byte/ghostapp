import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/ghost_widget.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/theme/app_theme.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'guest_mode_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),

                // Ghost animation
                const GhostWidget(
                  size: 140,
                  showAura: true,
                  isAnimated: true, // was `animate: true`
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(delay: 200.ms),

                const SizedBox(height: 32),

                // App name
                Text(
                  'GhostX',
                  style: Theme.of(context).textTheme.displayLarge,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Your AI companion that lives\nin your phone',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.ghostWhite.withOpacity(0.7),
                      ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms),

                const Spacer(),

                // Buttons
                Column(
                  children: [
                    CustomButton(
                      text: 'Get Started',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      width: double.infinity,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 800.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    CustomButton(
                      text: 'Sign In',
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
                        .fadeIn(duration: 600.ms, delay: 900.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),

                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GuestModeScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Try Guest Mode (10 min)',
                        style: TextStyle(
                          color: AppColors.auraEnd,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 1000.ms),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}