// lib/features/studio/gx_studio_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/gx_aura_widget.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import 'dart:math' as math;

class GXStudioScreen extends ConsumerStatefulWidget {
  const GXStudioScreen({super.key});

  @override
  ConsumerState<GXStudioScreen> createState() => _GXStudioScreenState();
}

class _GXStudioScreenState extends ConsumerState<GXStudioScreen> 
    with TickerProviderStateMixin {
  User? _user;
  bool _isLoading = true;
  late AnimationController _rotationController;
  final List<String> _unlockedDecor = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final userData = await StorageService.getUser();
      if (userData != null) {
        setState(() {
          _user = User.fromJson(userData);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.auraStart),
          ),
        ),
      );
    }

    final gxProfile = _user?.ghostProfile;
    final level = gxProfile?.level ?? 1;
    final roomStage = _getRoomStage(level);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: AppTheme.ghostWhite,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GX Studio',
                          style: TextStyle(
                            color: AppTheme.ghostWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Level $level • $roomStage',
                          style: TextStyle(
                            color: AppTheme.ghostWhite.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: AppColors.auraStart,
                      onPressed: () => _showCustomizationOptions(),
                    ),
                  ],
                ),
              ),

              // 3D Room visualization
              Expanded(
                child: Stack(
                  children: [
                    // Background room
                    _build3DRoom(level),

                    // Floating GX entity
                    Center(
                      child: AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              math.sin(_rotationController.value * 2 * math.pi) * 20,
                            ),
                            child: GXAuraWidget(
                              size: 120,
                              showParticles: true,
                              isAnimated: true,
                              level: level,
                            ),
                          );
                        },
                      ),
                    ),

                    // Room details overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildRoomDetails(level),
                    ),
                  ],
                ),
              ),

              // Bottom actions
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.store,
                        label: 'Shop',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Shop coming soon! ⚡'),
                              backgroundColor: AppColors.auraStart,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.inventory,
                        label: 'Inventory',
                        onTap: () => _showInventory(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.info_outline,
                        label: 'Progress',
                        onTap: () => _showProgressInfo(level),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DRoom(int level) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            AppColors.auraStart.withOpacity(0.1),
            Colors.black,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Floor grid
          CustomPaint(
            size: Size.infinite,
            painter: _FloorGridPainter(
              gridColor: AppColors.auraStart.withOpacity(0.2),
            ),
          ),

          // Wall lights (unlock at level 3)
          if (level >= 3) ..._buildWallLights(),

          // Floating panels (unlock at level 5)
          if (level >= 5) ..._buildFloatingPanels(),

          // Environment theme (unlock at level 7)
          if (level >= 7) _buildEnvironmentTheme(),
        ],
      ),
    );
  }

  List<Widget> _buildWallLights() {
    return [
      Positioned(
        top: 50,
        left: 20,
        child: _LightStrip(color: AppColors.auraStart),
      ),
      Positioned(
        top: 50,
        right: 20,
        child: _LightStrip(color: AppColors.auraEnd),
      ),
    ];
  }

  List<Widget> _buildFloatingPanels() {
    return [
      Positioned(
        top: 100,
        left: 40,
        child: _FloatingPanel(rotation: -15),
      ),
      Positioned(
        top: 120,
        right: 40,
        child: _FloatingPanel(rotation: 15),
      ),
    ];
  }

  Widget _buildEnvironmentTheme() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              AppColors.auraStart.withOpacity(0.2),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomDetails(int level) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.8),
            AppColors.auraStart.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.auraStart.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.auraStart.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getRoomStage(level),
                    style: const TextStyle(
                      color: AppTheme.ghostWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stage ${_getStageNumber(level)} / 5',
                    style: TextStyle(
                      color: AppTheme.ghostWhite.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.ghostAuraGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Level $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            current: level % 3 == 0 ? 3 : level % 3,
            max: 3,
            label: 'Next upgrade',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  String _getRoomStage(int level) {
    if (level >= 15) return 'Master Studio';
    if (level >= 10) return 'Advanced Space';
    if (level >= 7) return 'Evolving Room';
    if (level >= 5) return 'Growing Space';
    if (level >= 3) return 'Basic Room';
    return 'Empty Space';
  }

  int _getStageNumber(int level) {
    if (level >= 15) return 5;
    if (level >= 10) return 4;
    if (level >= 7) return 3;
    if (level >= 5) return 2;
    if (level >= 3) return 1;
    return 0;
  }

  void _showCustomizationOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.color_lens, color: AppColors.auraStart),
                title: const Text(
                  'Change Colors',
                  style: TextStyle(color: AppTheme.ghostWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Color customization coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.layers, color: AppColors.auraStart),
                title: const Text(
                  'Add Decor',
                  style: TextStyle(color: AppTheme.ghostWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showInventory();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInventory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Inventory',
          style: TextStyle(color: AppTheme.ghostWhite),
        ),
        content: const Text(
          'Your unlocked decor items will appear here.',
          style: TextStyle(color: AppTheme.ghostWhite),
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

  void _showProgressInfo(int level) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Studio Progress',
          style: TextStyle(color: AppTheme.ghostWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UnlockItem('Empty Space', level >= 1),
            _UnlockItem('Wall Lights', level >= 3),
            _UnlockItem('Floating Panels', level >= 5),
            _UnlockItem('Environment Theme', level >= 7),
            _UnlockItem('Full Customization', level >= 10),
            _UnlockItem('Animated Room', level >= 15),
          ],
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
}

// Helper widgets
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.auraStart, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.ghostWhite,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int max;
  final String label;

  const _ProgressBar({
    required this.current,
    required this.max,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.ghostWhite.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            Text(
              '$current / $max levels',
              style: const TextStyle(
                color: AppTheme.ghostWhite,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / max,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(AppColors.auraStart),
          ),
        ),
      ],
    );
  }
}

class _LightStrip extends StatelessWidget {
  final Color color;

  const _LightStrip({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 4,
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2.seconds, color: Colors.white24);
  }
}

class _FloatingPanel extends StatelessWidget {
  final double rotation;

  const _FloatingPanel({required this.rotation});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * math.pi / 180,
      child: Container(
        width: 60,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.auraStart.withOpacity(0.3),
              AppColors.auraEnd.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.auraStart.withOpacity(0.5),
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: 0, end: -20, duration: 3.seconds);
  }
}

class _UnlockItem extends StatelessWidget {
  final String label;
  final bool unlocked;

  const _UnlockItem(this.label, this.unlocked);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            unlocked ? Icons.check_circle : Icons.lock,
            color: unlocked ? AppColors.success : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: unlocked 
                  ? AppTheme.ghostWhite 
                  : AppTheme.ghostWhite.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorGridPainter extends CustomPainter {
  final Color gridColor;

  _FloorGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 40.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, size.height * 0.6),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines with perspective
    for (double y = size.height * 0.6; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}