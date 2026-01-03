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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final baseNavHeight = Responsive.responsive(
      context,
      mobile: 56.0,  // Reduced from 60
      tablet: 64.0,   // Reduced from 70
      desktop: 72.0,  // Reduced from 80
    );
    
    final iconSize = Responsive.responsive(
      context,
      mobile: 22.0,   // Reduced from 24
      tablet: 26.0,   // Reduced from 32
      desktop: 32.0,  // Reduced from 40
    );
    
    final fontSize = Responsive.responsive(
      context,
      mobile: 10.0,   // Reduced from 11
      tablet: 11.0,   // Reduced from 13
      desktop: 13.0,  // Reduced from 15
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
        top: false,
        child: SizedBox(
          height: baseNavHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.responsive(
                context,
                mobile: 16.0,   // Reduced from 24
                tablet: 32.0,   // Reduced from 48
                desktop: 48.0,  // Reduced from 64
              ),
              vertical: 4.0,    // Reduced from 8
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
    final isTablet = context.isTablet;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 10,  // Reduced
          vertical: isTablet ? 6 : 4,      // Reduced
        ),
        decoration: isActive
            ? BoxDecoration(
                gradient: AppColors.ghostAuraGradient,
                borderRadius: BorderRadius.circular(AppRadius.full),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: isActive 
                  ? Colors.white 
                  : AppTheme.ghostWhite.withOpacity(0.5),
              size: iconSize,
            ),
            SizedBox(height: isTablet ? 3 : 2),  // Reduced
            Text(
              item.label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : AppTheme.ghostWhite.withOpacity(0.5),
                fontSize: fontSize,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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