import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/storage_service.dart';
import 'core/services/wallpaper_sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

// Provider for wallpaper service
final wallpaperServiceProvider = ChangeNotifierProvider<WallpaperSyncService>((ref) {
  return WallpaperSyncService();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await StorageService.init();
  
  // Initialize wallpaper service
  final wallpaperService = WallpaperSyncService();
  await wallpaperService.initialize();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
  
  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  runApp(
    ProviderScope(
      overrides: [
        wallpaperServiceProvider.overrideWith((ref) => wallpaperService),
      ],
      child: const GhostXApp(),
    ),
  );
}

class GhostXApp extends ConsumerWidget {
  const GhostXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch wallpaper service for theme changes
    final wallpaperService = ref.watch(wallpaperServiceProvider);
    
    return MaterialApp(
      title: 'GhostX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme.copyWith(
        // Update theme with wallpaper colors
        colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
          primary: wallpaperService.currentColors?.primary ?? AppTheme.primaryPurple,
          secondary: wallpaperService.currentColors?.accent ?? AppTheme.accentCyan,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}