import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../core/widgets/gradient_background.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/wallpaper_sync_service.dart';
import '../../core/services/background_image_services.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../main.dart';
import '../auth/welcome_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await StorageService.getUser();
    if (userData != null) {
      setState(() {
        _user = User.fromJson(userData);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Sign Out?',
          style: TextStyle(color: AppTheme.ghostWhite),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppTheme.ghostWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearAll();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPermissionStatus() async {
    // Check the correct permission based on Android version
    PermissionStatus status;
    
    try {
      // Try photos permission first (Android 13+)
      status = await Permission.photos.status;
      
      // If photos isn't supported, try storage (Android 12 and below)
      if (!status.isGranted) {
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isGranted) {
          status = storageStatus;
        }
      }
    } catch (e) {
      // Fallback to storage permission
      status = await Permission.storage.status;
    }
    
    final isPermanentlyDenied = status.isPermanentlyDenied;
    final isDenied = status.isDenied;
    final isGranted = status.isGranted;
    final isLimited = status.isLimited;
    
    if (!mounted) return;
    
    String message;
    Color color;
    IconData icon;
    
    if (isGranted) {
      message = '✅ Media/Storage permission is GRANTED\nWallpaper sync should work!';
      color = AppColors.success;
      icon = Icons.check_circle;
    } else if (isPermanentlyDenied) {
      message = '🚫 Permission PERMANENTLY DENIED\nYou must manually grant it in settings';
      color = AppColors.error;
      icon = Icons.block;
    } else if (isDenied) {
      message = '❌ Permission DENIED\nTry requesting again or use Force Grant';
      color = AppColors.warning;
      icon = Icons.warning;
    } else if (isLimited) {
      message = '⚠️ Permission LIMITED\nSome features may not work';
      color = AppColors.warning;
      icon = Icons.warning;
    } else {
      message = '❓ Permission status UNKNOWN';
      color = AppColors.auraStart;
      icon = Icons.help;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            const Text(
              'Permission Status',
              style: TextStyle(color: AppTheme.ghostWhite, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.ghostWhite,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow('Granted', isGranted ? '✅ Yes' : '❌ No'),
                  _DetailRow('Denied', isDenied ? '⚠️ Yes' : '✅ No'),
                  _DetailRow('Permanently Denied', isPermanentlyDenied ? '🚫 Yes' : '✅ No'),
                  _DetailRow('Limited', isLimited ? '⚠️ Yes' : '✅ No'),
                ],
              ),
            ),
            if (isPermanentlyDenied) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppColors.warning, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Use "Force Grant Permission" to manually enable in settings',
                        style: TextStyle(
                          color: AppTheme.ghostWhite,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (isPermanentlyDenied)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showForcePermissionDialog(
                  ref.read(wallpaperServiceProvider),
                );
              },
              child: const Text('Open Settings'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showForcePermissionDialog(WallpaperSyncService service) async {
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Row(
        children: [
          Icon(Icons.settings, color: AppColors.auraStart),
          const SizedBox(width: 12),
          const Text(
            'Open Settings?',
            style: TextStyle(color: AppTheme.ghostWhite, fontSize: 18),
          ),
        ],
      ),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will open your device settings where you can manually grant storage permission.',
              style: TextStyle(color: AppTheme.ghostWhite),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.auraStart.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.auraStart.withOpacity(0.3),
                ),
              ),
                                child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📱 Steps:',
                    style: TextStyle(
                      color: AppTheme.ghostWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Tap "Open Settings" below\n'
                    '2. Find "Permissions" section\n'
                    '3. Look for "Photos and videos" or "Media"\n'
                    '4. Enable the permission\n'
                    '5. Return to GhostX\n'
                    '6. Tap "Refresh Wallpaper"',
                    style: TextStyle(
                      color: AppTheme.ghostWhite,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.auraStart,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (shouldOpen == true) {
      try {
        // Import permission_handler at the top of your file
        await openAppSettings();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '💡 After granting permission, come back and tap "Refresh Wallpaper"',
              ),
              backgroundColor: AppColors.auraStart,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Got it',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Could not open settings. Try manually.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showWallpaperDetailsDialog(WallpaperSyncService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          '🎨 Wallpaper Sync Details',
          style: TextStyle(color: AppTheme.ghostWhite, fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Status', service.isEnabled ? '✅ Enabled' : '❌ Disabled'),
              _DetailRow('Permission', service.hasPermission ? '✅ Granted' : '❌ Denied'),
              _DetailRow('Loading', service.isLoading ? '⏳ Yes' : '✅ No'),
              _DetailRow('Wallpaper Data', service.wallpaperBytes != null ? '✅ Loaded' : '❌ None'),
              const SizedBox(height: 12),
              const Text(
                'Current Colors:',
                style: TextStyle(
                  color: AppTheme.ghostWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (service.currentColors != null) ...[
                _ColorRow('Primary', service.currentColors!.primary),
                _ColorRow('Accent', service.currentColors!.accent),
                _ColorRow('Aura Start', service.currentColors!.auraStart),
                _ColorRow('Aura End', service.currentColors!.auraEnd),
                _ColorRow('Ghost Tint', service.currentColors!.ghostTint),
                _ColorRow('Particle', service.currentColors!.particleColor),
              ] else
                const Text(
                  'No colors loaded',
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ghostProfile = _user?.ghostProfile;
    final wallpaperService = ref.watch(wallpaperServiceProvider);
    final bgService = ref.watch(backgroundImageServiceProvider); // watch provider

    return Scaffold(
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.ghostAuraGradient,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👻', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _user?.displayName ?? _user?.username ?? 'Ghost User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatBadge(
                          label: 'Level',
                          value: '${ghostProfile?.level ?? 1}',
                        ),
                        const SizedBox(width: 12),
                        _StatBadge(
                          label: 'XP',
                          value: '${ghostProfile?.totalXP ?? 0}',
                        ),
                        const SizedBox(width: 12),
                        _StatBadge(
                          label: 'Coins',
                          value: '${ghostProfile?.coins ?? 0}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🎨 WALLPAPER SYNC SECTION (NEW!)
              const _SectionHeader(title: 'Wallpaper Sync'),
              
              // Status card
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: wallpaperService.hasPermission
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.error.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          wallpaperService.hasPermission
                              ? Icons.check_circle
                              : Icons.error,
                          color: wallpaperService.hasPermission
                              ? AppColors.success
                              : AppColors.error,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wallpaperService.hasPermission
                                    ? '✅ Wallpaper Sync Active'
                                    : '❌ Permission Required',
                                style: const TextStyle(
                                  color: AppTheme.ghostWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                wallpaperService.hasPermission
                                    ? 'Theme adapts to your wallpaper'
                                    : 'Grant permission to enable',
                                style: TextStyle(
                                  color: AppTheme.ghostWhite.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: wallpaperService.isEnabled,
                          onChanged: (_) => wallpaperService.toggle(),
                          activeColor: AppColors.auraStart,
                        ),
                      ],
                    ),
                    
                    // Show loading indicator
                    if (wallpaperService.isLoading) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 4),
                      Text(
                        'Extracting wallpaper colors...',
                        style: TextStyle(
                          color: AppTheme.ghostWhite.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    
                    // Show current colors preview
                    if (wallpaperService.currentColors != null) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Current Theme Colors:',
                        style: TextStyle(
                          color: AppTheme.ghostWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _ColorPreview(
                            color: wallpaperService.currentColors!.primary,
                            label: 'Primary',
                          ),
                          const SizedBox(width: 8),
                          _ColorPreview(
                            color: wallpaperService.currentColors!.accent,
                            label: 'Accent',
                          ),
                          const SizedBox(width: 8),
                          _ColorPreview(
                            color: wallpaperService.currentColors!.ghostTint,
                            label: 'Ghost',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              if (!wallpaperService.hasPermission) ...[
                _SettingsTile(
                  icon: Icons.lock_open,
                  title: 'Request Permission',
                  subtitle: 'Allow GhostX to read your wallpaper',
                  onTap: () async {
                    await wallpaperService.requestPermission();
                    if (mounted) {
                      final hasPermission = wallpaperService.hasPermission;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            hasPermission
                                ? '✅ Permission granted!'
                                : '❌ Permission denied',
                          ),
                          backgroundColor: hasPermission
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      );
                      
                      // If permission still denied, suggest force grant
                      if (!hasPermission) {
                        await Future.delayed(const Duration(seconds: 2));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                '💡 Try "Force Grant Permission" below',
                              ),
                              backgroundColor: AppColors.auraStart,
                              action: SnackBarAction(
                                label: 'Open',
                                textColor: Colors.white,
                                onPressed: () => _showForcePermissionDialog(wallpaperService),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                _SettingsTile(
                  icon: Icons.settings,
                  title: 'Force Grant Permission',
                  subtitle: 'Open app settings to manually grant',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'MANUAL',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () async {
                    await _showForcePermissionDialog(wallpaperService);
                  },
                ),
              ],

              if (wallpaperService.hasPermission)
                _SettingsTile(
                  icon: Icons.refresh,
                  title: 'Refresh Wallpaper',
                  subtitle: 'Extract colors from current wallpaper',
                  onTap: () async {
                    await wallpaperService.refresh();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Wallpaper colors refreshed!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),

              _SettingsTile(
                icon: Icons.info_outline,
                title: 'View Details',
                subtitle: 'See full wallpaper sync status',
                onTap: () => _showWallpaperDetailsDialog(wallpaperService),
              ),

              _SettingsTile(
                icon: Icons.bug_report,
                title: 'Test Permission Status',
                subtitle: 'Check current permission state',
                onTap: () async {
                  await _checkPermissionStatus();
                },
              ),

              _SettingsTile(
                icon: Icons.restore,
                title: 'Reset to Default Colors',
                subtitle: 'Use original GhostX theme',
                onTap: () {
                  wallpaperService.setManualColors(
                    WallpaperColors.defaultColors(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Reset to default colors'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),

              // Quick test guide
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.auraStart.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.auraStart.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.science,
                          color: AppColors.auraStart,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Quick Test Guide',
                          style: TextStyle(
                            color: AppTheme.ghostWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Change your device wallpaper\n'
                      '2. Return to GhostX\n'
                      '3. Tap "Refresh Wallpaper"\n'
                      '4. Watch the colors update!',
                      style: TextStyle(
                        color: AppTheme.ghostWhite.withOpacity(0.7),
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🖼️ CUSTOM BACKGROUND SECTION (NEW!)
              const _SectionHeader(title: 'Custom Background'),
              
              _SettingsTile(
                icon: Icons.wallpaper,
                title: 'Background Image',
                subtitle: bgService.hasBackground ? 'Tap to change' : 'Not set - using default',
                trailing: bgService.hasBackground
                    ? Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            bgService.backgroundImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : null,
                onTap: () async {
                  await _showBackgroundOptions();
                },
              ),

              const SizedBox(height: 24),

               // Account section
               const _SectionHeader(title: 'Account'),
              _SettingsTile(
                icon: Icons.person,
                title: 'Edit Profile',
                onTap: () {
                  // TODO: Navigate to profile edit
                },
              ),
              _SettingsTile(
                icon: Icons.upgrade,
                title: 'Upgrade to Pro',
                subtitle: _user?.plan == 'pro' ? 'Active' : 'Unlock all features',
                trailing: _user?.plan == 'pro'
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  // TODO: Navigate to subscription
                },
              ),

              const SizedBox(height: 24),

              const _SectionHeader(title: 'Customization'),
              _SettingsTile(
                icon: Icons.psychology,
                title: 'Ghost Personality',
                subtitle: ghostProfile?.personality ?? 'chill',
                onTap: () {
                  // TODO: Navigate to personality settings
                },
              ),

              const SizedBox(height: 24),

              const _SectionHeader(title: 'Notifications'),
              _SettingsTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Toggle notifications
                  },
                  activeColor: AppColors.auraStart,
                ),
              ),
              _SettingsTile(
                icon: Icons.voice_chat,
                title: 'Voice Trigger',
                subtitle: 'Wake Ghost with "Hey Ghost"',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: Toggle voice trigger
                  },
                  activeColor: AppColors.auraStart,
                ),
              ),

              const SizedBox(height: 24),

              const _SectionHeader(title: 'Privacy & Security'),
              _SettingsTile(
                icon: Icons.lock,
                title: 'Privacy Settings',
                onTap: () {
                  // TODO: Navigate to privacy settings
                },
              ),
              _SettingsTile(
                icon: Icons.delete,
                title: 'Clear Chat History',
                onTap: () {
                  // TODO: Clear chat
                },
              ),

              const SizedBox(height: 24),

              const _SectionHeader(title: 'About'),
              _SettingsTile(
                icon: Icons.info,
                title: 'About GhostX',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  // TODO: Show about dialog
                },
              ),
              _SettingsTile(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {
                  // TODO: Navigate to support
                },
              ),
              _SettingsTile(
                icon: Icons.description,
                title: 'Terms & Privacy',
                onTap: () {
                  // TODO: Navigate to legal
                },
              ),

              const SizedBox(height: 24),

              // Sign out button
              GestureDetector(
                onTap: _signOut,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: AppColors.error),
                      SizedBox(width: 12),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Show options to select or remove custom background
  Future<void> _showBackgroundOptions() async {
    final bgService = ref.read(backgroundImageServiceProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.auraStart),
                title: const Text('Choose from Gallery', style: TextStyle(color: AppTheme.ghostWhite)),
                onTap: () async {
                  Navigator.pop(context);
                  final success = await bgService.pickFromGallery();
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Background updated!'), backgroundColor: AppColors.success),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.auraStart),
                title: const Text('Take a Photo', style: TextStyle(color: AppTheme.ghostWhite)),
                onTap: () async {
                  Navigator.pop(context);
                  final success = await bgService.pickFromCamera();
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Background updated!'), backgroundColor: AppColors.success),
                    );
                  }
                },
              ),
              if (bgService.hasBackground)
                ListTile(
                  leading: Icon(Icons.delete, color: AppColors.error),
                  title: const Text('Remove Background', style: TextStyle(color: AppTheme.ghostWhite)),
                  onTap: () async {
                    Navigator.pop(context);
                    await bgService.removeBackground();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🗑️ Background removed'), backgroundColor: AppColors.warning),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widgets
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.ghostWhite.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.ghostWhite,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorRow(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.ghostWhite.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white30),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                style: const TextStyle(
                  color: AppTheme.ghostWhite,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorPreview extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorPreview({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white30),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.ghostWhite.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.ghostWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.auraStart, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.ghostWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppTheme.ghostWhite.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.ghostWhite.withOpacity(0.3),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;

  const _StatBadge({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}