// lib/features/home/home_screen.dart - GX REBRANDED
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../ghost_space/gx_space_screen.dart';
import '../chat/gx_talk_screen.dart';
import '../tasks/tasks_screen.dart';
import '../network/gx_network_screen.dart';
import '../studio/gx_studio_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const GXCoreScreen(), // Main GX presence (renamed from GhostSpaceScreen)
    const GXTalkScreen(), // Chat (renamed from ChatScreen)
    const TasksScreen(), // Tasks & Quests
    const GXNetworkScreen(), // Community (new)
    const GXStudioScreen(), // 3D Room (new)
  ];

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.auto_awesome, label: 'GX', emoji: '⚡'),
    _NavItem(icon: Icons.chat_bubble_outline, label: 'Talk', emoji: '💬'),
    _NavItem(icon: Icons.task_alt, label: 'Tasks', emoji: '✓'),
    _NavItem(icon: Icons.people_outline, label: 'Network', emoji: '🌐'),
    _NavItem(icon: Icons.view_in_ar, label: 'Studio', emoji: '🏠'),
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
    final baseNavHeight = Responsive.responsive(
      context,
      mobile: 70.0,
      tablet: 80.0,
      desktop: 90.0,
    );
    
    final iconSize = Responsive.responsive(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 34.0,
    );
    
    final fontSize = Responsive.responsive(
      context,
      mobile: 11.0,
      tablet: 12.0,
      desktop: 14.0,
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
        border: Border(
          top: BorderSide(
            color: AppColors.auraStart.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: baseNavHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.responsive(
                context,
                mobile: 8.0,
                tablet: 16.0,
                desktop: 24.0,
              ),
              vertical: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navItems.length,
                (index) => _NavItemWidget(
                  item: _navItems[index],
                  isActive: _currentIndex == index,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  onTap: () {
                    setState(() => _currentIndex = index);
                    HapticFeedback.selectionClick();
                  },
                ),
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
  final String emoji;

  _NavItem({required this.icon, required this.label, required this.emoji});
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
    final isTablet = context.isTablet;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 6,
          vertical: isTablet ? 6 : 4,
        ),
        decoration: isActive
            ? BoxDecoration(
                gradient: AppColors.ghostAuraGradient,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.auraStart.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use emoji for active, icon for inactive (more modern)
            isActive
                ? Text(
                    item.emoji,
                    style: TextStyle(fontSize: iconSize),
                  )
                : Icon(
                    item.icon,
                    color: AppTheme.ghostWhite.withOpacity(0.5),
                    size: iconSize,
                  ),
            SizedBox(height: isTablet ? 4 : 2),
            Text(
              item.label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : AppTheme.ghostWhite.withOpacity(0.5),
                fontSize: fontSize,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}