import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../ghost_space/ghost_space_screen.dart';
import '../chat/chat_screen.dart';
import '../tasks/tasks_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const GhostSpaceScreen(),
    const ChatScreen(),
    const TasksScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0),
            Colors.black.withOpacity(0.95),
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.auto_awesome,
                label: 'Ghost',
                isActive: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                isActive: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavItem(
                icon: Icons.task_alt,
                label: 'Tasks',
                isActive: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                isActive: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                gradient: AppColors.ghostAuraGradient,
                borderRadius: BorderRadius.circular(AppRadius.full),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppTheme.ghostWhite.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : AppTheme.ghostWhite.withOpacity(0.5),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}