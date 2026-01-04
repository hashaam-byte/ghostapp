import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/storage_service.dart';
import 'core/services/wallpaper_sync_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/voice_service.dart';
import 'core/services/background_image_services.dart'; // added import
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

// 🔥 Global Providers
final wallpaperServiceProvider = ChangeNotifierProvider<WallpaperSyncService>((ref) {
  return WallpaperSyncService();
});

// 🖼️ Background Image Provider (NEW!)
final backgroundImageServiceProvider = ChangeNotifierProvider<BackgroundImageService>((ref) {
  return BackgroundImageService();
});

final voiceServiceProvider = Provider<VoiceService>((ref) {
  return VoiceService();
});

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
  
  // 🗄️ Step 1: Initialize Storage (SharedPreferences)
  debugPrint('🗄️ Initializing Storage...');
  await StorageService.init();
  debugPrint('✅ Storage initialized');
  
  // 🎨 Step 2: Initialize Wallpaper Service
  // THIS IS WHERE THE PERMISSION DIALOG WILL SHOW (Android 6-12 only)
  debugPrint('🎨 Initializing Wallpaper Service...');
  final wallpaperService = WallpaperSyncService();
  
  try {
    // This will:
    // 1. Load saved colors (instant)
    // 2. Request permission (shows dialog for Android 6-12)
    // 3. Extract wallpaper if permission granted
    await wallpaperService.initialize();
    
    if (wallpaperService.hasPermission) {
      debugPrint('✅ Wallpaper colors loaded from device wallpaper');
    } else {
      debugPrint('ℹ️ Using default colors (wallpaper permission not granted)');
    }
  } catch (e) {
    debugPrint('⚠️ Wallpaper initialization failed: $e');
    debugPrint('ℹ️ Using default colors');
  }
  
  // 🔔 Step 3: Initialize Notification Service
  debugPrint('🔔 Initializing Notification Service...');
  final notificationService = NotificationService();
  
  try {
    await notificationService.initialize();
    debugPrint('✅ Notification service initialized');
  } catch (e) {
    debugPrint('⚠️ Notification initialization failed: $e');
  }
  
  // 🎙️ Step 4: Initialize Voice Service
  debugPrint('🎙️ Initializing Voice Service...');
  final voiceService = VoiceService();
  
  try {
    await voiceService.initialize();
    debugPrint('Voice service initialized: ${voiceService.isInitialized}');
    debugPrint('✅ Voice service initialized');
  } catch (e) {
    debugPrint('⚠️ Voice initialization failed: $e');
  }
  
  // 🖼️ Step 5: Initialize Background Image Service (NEW!)
  debugPrint('🖼️ Initializing Background Image Service...');
  final bgImageService = BackgroundImageService();
  
  try {
    await bgImageService.initialize();
    debugPrint('✅ Background image service initialized');
  } catch (e) {
    debugPrint('⚠️ Background image initialization failed: $e');
  }
  
  debugPrint('🚀 All services initialized - launching app');
  
  runApp(
    ProviderScope(
      overrides: [
        wallpaperServiceProvider.overrideWith((ref) => wallpaperService),
        notificationServiceProvider.overrideWith((ref) => notificationService),
        voiceServiceProvider.overrideWith((ref) => voiceService),
        backgroundImageServiceProvider.overrideWith((ref) => bgImageService), // NEW!
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