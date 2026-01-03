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

// 🔥 Global Providers
final wallpaperServiceProvider = ChangeNotifierProvider<WallpaperSyncService>((ref) {
  return WallpaperSyncService();
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
  
  // 🗄️ Step 1: Initialize Hive (no permissions needed)
  debugPrint('🗄️ Initializing Hive...');
  await Hive.initFlutter();
  await StorageService.init();
  debugPrint('✅ Hive initialized');
  
  // 🎨 Step 2: Initialize Wallpaper Service (requests READ_EXTERNAL_STORAGE permission)
  debugPrint('🎨 Initializing Wallpaper Service...');
  final wallpaperService = WallpaperSyncService();
  
  try {
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
  
  // ⏳ Wait 800ms to ensure wallpaper permission request completes
  await Future.delayed(const Duration(milliseconds: 800));
  
  // 🔔 Step 3: Initialize Notification Service (requests POST_NOTIFICATIONS permission)
  debugPrint('🔔 Initializing Notification Service...');
  final notificationService = NotificationService();
  
  try {
    await notificationService.initialize();
    debugPrint('✅ Notification service initialized');
  } catch (e) {
    debugPrint('⚠️ Notification initialization failed: $e');
    debugPrint('ℹ️ Notifications may not work');
  }
  
  // ⏳ Wait 500ms to ensure notification permission request completes
  await Future.delayed(const Duration(milliseconds: 500));
  
  // 🎙️ Step 4: Initialize Voice Service (requests RECORD_AUDIO permission)
  debugPrint('🎙️ Initializing Voice Service...');
  final voiceService = VoiceService();
  
  try {
    await voiceService.initialize();
    debugPrint('✅ Voice service initialized');
  } catch (e) {
    debugPrint('⚠️ Voice initialization failed: $e');
    debugPrint('ℹ️ Voice features may not work');
  }
  
  debugPrint('🚀 All services initialized - launching app');
  
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