import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/wallpaper_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_gate.dart';
import '../tutorial/tutorial_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Initialize API client
      ApiClient.init();

      // Load saved wallpaper colors first
      final savedColors = await WallpaperService.loadSavedColors();
      if (savedColors != null) {
        WallpaperService.applyColors(savedColors);
        if (mounted) setState(() {});
      }

      // Extract new wallpaper colors in background
      WallpaperService.extractWallpaperColors().then((colors) {
        WallpaperService.applyColors(colors);
        if (mounted) setState(() {});
      });

      // Wait minimum splash time for animation
      await Future.delayed(const Duration(seconds: 2));

      // Navigate based on state
      if (!mounted) return;
      
      final hasToken = await StorageService.getToken() != null;
      final tutorialComplete = StorageService.isTutorialComplete();

      if (!hasToken) {
        // No auth - go to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      } else if (!tutorialComplete) {
        // Has auth but no tutorial - show tutorial
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const InteractiveTutorialScreen()),
        );
      } else {
        // All good - go to main app
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthGate()), // Will auto-navigate to home
        );
      }
    } catch (e) {
      debugPrint('Splash init error: $e');
      // Fallback to auth gate
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

          // Ghost logo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ghost icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.ghostAuraGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.auraStart.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '👻',
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2.seconds, color: Colors.white24)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.05, 1.05),
                      duration: 2.seconds,
                      curve: Curves.easeInOut,
                    ),

                const SizedBox(height: 32),

                // App name
                Text(
                  'GhostX',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Your AI companion',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        letterSpacing: 1.5,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms),
              ],
            ),
          ),

          // Loading indicator
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.auraEnd),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fade(duration: 1.seconds),
            ),
          ),
        ],
      ),
    );
  }
}