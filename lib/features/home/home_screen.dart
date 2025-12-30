import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../ghost_space/ghost_space_screen.dart';
import '../chat/chat_screen.dart';
import '../tasks/tasks_screen.dart';
import '../settings/settings_screen.dart';
import 'package:flutter/services.dart';

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

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.auto_awesome, label: 'Ghost'),
    _NavItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
    _NavItem(icon: Icons.task_alt, label: 'Tasks'),
    _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    // Responsive sizing
    final navHeight = Responsive.navHeight(context);
    final iconSize = Responsive.iconSize(context);
    final fontSize = Responsive.fontSize(
      context,
      mobile: 11,
      tablet: 13,
      desktop: 15,
    );

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
          height: navHeight,
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.responsive(
              context,
              mobile: 24.0,
              tablet: 48.0,
              desktop: 64.0,
            ),
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _navItems.length,
              (index) => _NavItemWidget(
                item: _navItems[index],
                isActive: _currentIndex == index,
                iconSize: iconSize,
                fontSize: fontSize,
                onTap: () {
                  setState(() => _currentIndex = index);
                  // Add haptic feedback
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final double iconSize;
  final double fontSize;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.iconSize,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.isTablet ? 20 : 16,
          vertical: context.isTablet ? 12 : 8,
        ),
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
              item.icon,
              color: isActive 
                  ? Colors.white 
                  : AppTheme.ghostWhite.withOpacity(0.5),
              size: iconSize,
            ),
            SizedBox(height: context.isTablet ? 6 : 4),
            Text(
              item.label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : AppTheme.ghostWhite.withOpacity(0.5),
                fontSize: fontSize,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

