import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/storage_service.dart';
import 'core/services/wallpaper_sync_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/voice_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

// 🔥 Global Provider for Wallpaper Service
final wallpaperServiceProvider = ChangeNotifierProvider<WallpaperSyncService>((ref) {
  return WallpaperSyncService();
});

// 🔥 Global Provider for Voice Service
final voiceServiceProvider = Provider<VoiceService>((ref) {
  return VoiceService();
});

// 🔥 Global Provider for Notification Service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔧 System UI Configuration
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
  
  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // 🗄️ Initialize Hive (local storage)
  await Hive.initFlutter();
  await StorageService.init();
  
  // 🎨 Initialize Wallpaper Service
  final wallpaperService = WallpaperSyncService();
  await wallpaperService.initialize();
  
  // 🔥 CRITICAL: Extract wallpaper colors on startup
  try {
    await wallpaperService.extractAndApply();
  } catch (e) {
    debugPrint('Wallpaper extraction failed (using defaults): $e');
  }
  
  // 🔔 Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // 🎙️ Initialize Voice Service
  final voiceService = VoiceService();
  await voiceService.initialize();
  
  runApp(
    ProviderScope(
      overrides: [
        wallpaperServiceProvider.overrideWith((ref) => wallpaperService),
        notificationServiceProvider.overrideWith((ref) => notificationService),
        voiceServiceProvider.overrideWith((ref) => voiceService),
      ],
      child: const GhostXApp(),
    ),
  );
}

class GhostXApp extends ConsumerWidget {
  const GhostXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 Watch wallpaper service for theme changes
    final wallpaperService = ref.watch(wallpaperServiceProvider);
    
    return MaterialApp(
      title: 'GhostX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme.copyWith(
        // 🎨 Update theme with wallpaper colors
        colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
          primary: wallpaperService.currentColors?.primary ?? AppTheme.primaryPurple,
          secondary: wallpaperService.currentColors?.accent ?? AppTheme.accentCyan,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}