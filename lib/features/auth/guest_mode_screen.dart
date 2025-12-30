import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/ghost_widget.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/services/api_client.dart';
import '../../core/services/storage_service.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../tutorial/tutorial_screen.dart';

class GuestModeScreen extends StatefulWidget {
  const GuestModeScreen({super.key});

  @override
  State<GuestModeScreen> createState() => _GuestModeScreenState();
}

class _GuestModeScreenState extends State<GuestModeScreen> {
  bool _isLoading = false;

  Future<void> _startGuestMode() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post(ApiConfig.guest);

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final user = data['user'];

        // Save token and user data
        await StorageService.saveToken(token);
        await StorageService.saveUser(user);
        await StorageService.setGuestMode(true);

        if (!mounted) return;

        // Navigate to tutorial
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const TutorialScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.ghostWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),

                // Ghost animation
                const GhostWidget(
                  size: 120,
                  showAura: true,
                  isAnimated: true, // was `animate: true`
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(delay: 200.ms),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Try Guest Mode',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms),

                const SizedBox(height: 16),

                // Description
                Text(
                  'Experience GhostX for 10 minutes\nNo signup required',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.ghostWhite.withOpacity(0.7),
                      ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms),

                const SizedBox(height: 40),

                // Features
                _buildFeatureItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat with Ghost AI',
                  delay: 800,
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.task_alt,
                  title: 'Create tasks & quests',
                  delay: 900,
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.explore_outlined,
                  title: 'Explore all features',
                  delay: 1000,
                ),

                const Spacer(),

                // Start Button
                CustomButton(
                  text: 'Start Guest Mode',
                  onPressed: _startGuestMode,
                  isLoading: _isLoading,
                  width: double.infinity,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 1100.ms),

                const SizedBox(height: 16),

                // Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your data will be deleted after 10 minutes.\nSign up to save your progress.',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 1200.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.ghostAuraGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.ghostWhite,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: delay.ms).slideX(begin: -0.2);
  }
}