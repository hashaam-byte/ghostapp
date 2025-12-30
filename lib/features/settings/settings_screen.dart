import 'package:flutter/material.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../auth/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ghostProfile = _user?.ghostProfile;

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

              // Settings sections
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
                icon: Icons.palette,
                title: 'Appearance',
                subtitle: 'Wallpaper sync, theme, colors',
                onTap: () {
                  // TODO: Navigate to appearance settings
                },
              ),
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