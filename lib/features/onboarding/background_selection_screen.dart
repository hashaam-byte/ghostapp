// lib/features/onboarding/background_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';
import '../tutorial/tutorial_screen.dart';

class BackgroundSelectionScreen extends ConsumerStatefulWidget {
  const BackgroundSelectionScreen({super.key});

  @override
  ConsumerState<BackgroundSelectionScreen> createState() => _BackgroundSelectionScreenState();
}

class _BackgroundSelectionScreenState extends ConsumerState<BackgroundSelectionScreen> {
  bool _isSelecting = false;

  Future<void> _pickFromGallery() async {
    setState(() => _isSelecting = true);

    final service = ref.read(backgroundImageServiceProvider);
    final success = await service.pickFromGallery();

    if (!mounted) return;

    setState(() => _isSelecting = false);

    if (success) {
      _showSuccessAndContinue();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to select image'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickFromCamera() async {
    setState(() => _isSelecting = true);

    final service = ref.read(backgroundImageServiceProvider);
    final success = await service.pickFromCamera();

    if (!mounted) return;

    setState(() => _isSelecting = false);

    if (success) {
      _showSuccessAndContinue();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to capture image'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _skipAndContinue() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const InteractiveTutorialScreen(),
      ),
    );
  }

  void _showSuccessAndContinue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Background set! You can change it anytime in settings.'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const InteractiveTutorialScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgService = ref.watch(backgroundImageServiceProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.auraStart.withOpacity(0.3),
                    Colors.black,
                    AppColors.auraEnd.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isSelecting ? null : _skipAndContinue,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppTheme.ghostWhite.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.ghostAuraGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.wallpaper,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 200.ms),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Choose Your Background',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 300.ms),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Personalize your GhostX experience\nwith a custom background',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.ghostWhite.withOpacity(0.7),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms),

                  const SizedBox(height: 48),

                  // Preview (if image selected)
                  if (bgService.hasBackground)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.success,
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            bgService.backgroundImage!,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 48,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(),

                  const Spacer(),

                  // Action buttons
                  Column(
                    children: [
                      CustomButton(
                        text: 'Choose from Gallery',
                        icon: Icons.photo_library,
                        onPressed: _isSelecting ? null : _pickFromGallery,
                        isLoading: _isSelecting,
                        width: double.infinity,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 500.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 16),

                      CustomButton(
                        text: 'Take a Photo',
                        icon: Icons.camera_alt,
                        isOutlined: true,
                        onPressed: _isSelecting ? null : _pickFromCamera,
                        width: double.infinity,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 600.ms)
                          .slideY(begin: 0.2, end: 0),

                      if (bgService.hasBackground) ...[
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Continue',
                          onPressed: _isSelecting ? null : _showSuccessAndContinue,
                          width: double.infinity,
                          color: AppColors.success,
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 700.ms)
                            .slideY(begin: 0.2, end: 0),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.auraStart.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.auraStart.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.auraStart,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You can always change this later in settings',
                            style: TextStyle(
                              color: AppTheme.ghostWhite.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 800.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}