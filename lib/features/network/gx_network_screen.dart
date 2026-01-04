// lib/features/network/gx_network_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_client.dart';
import '../../core/config/api_config.dart';
import '../../models/ghost_profile_model.dart';

class GXNetworkScreen extends StatefulWidget {
  const GXNetworkScreen({super.key});

  @override
  State<GXNetworkScreen> createState() => _GXNetworkScreenState();
}

class _GXNetworkScreenState extends State<GXNetworkScreen> 
    with TickerProviderStateMixin {
  List<NearbyGhost> _nearbyGhosts = [];
  bool _isLoading = true;
  String _selectedTab = 'nearby'; // nearby, events, zones
  late AnimationController _mapAnimationController;

  @override
  void initState() {
    super.initState();
    _loadNearbyGhosts();
    
    _mapAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _mapAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadNearbyGhosts() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.get(ApiConfig.nearbyGhosts);

      if (response.statusCode == 200) {
        final data = response.data;
        final ghostsJson = data['nearbyGhosts'] as List;

        setState(() {
          _nearbyGhosts = ghostsJson
              .map((json) => NearbyGhost.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GX Network',
                          style: TextStyle(
                            color: AppTheme.ghostWhite,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Discover the aura around you',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.map),
                      color: AppColors.auraStart,
                      iconSize: 28,
                      onPressed: () {
                        _showAbstractMap();
                      },
                    ),
                  ],
                ),
              ),

              // Tab selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Nearby',
                      icon: Icons.people,
                      isSelected: _selectedTab == 'nearby',
                      onTap: () => setState(() => _selectedTab = 'nearby'),
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: 'Events',
                      icon: Icons.event,
                      isSelected: _selectedTab == 'events',
                      onTap: () => setState(() => _selectedTab = 'events'),
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: 'Zones',
                      icon: Icons.location_city,
                      isSelected: _selectedTab == 'zones',
                      onTap: () => setState(() => _selectedTab = 'zones'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedTab) {
      case 'nearby':
        return _buildNearbyList();
      case 'events':
        return _buildEventsList();
      case 'zones':
        return _buildZonesList();
      default:
        return _buildNearbyList();
    }
  }

  Widget _buildNearbyList() {
    if (_nearbyGhosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌌', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'No GX users nearby',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Keep your location enabled to discover',
              style: TextStyle(
                color: AppTheme.ghostWhite.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNearbyGhosts,
      color: AppColors.auraStart,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _nearbyGhosts.length,
        itemBuilder: (context, index) {
          final ghost = _nearbyGhosts[index];
          return _GhostCard(ghost: ghost)
              .animate()
              .fadeIn(duration: 400.ms, delay: (50 * index).ms)
              .slideX(begin: -0.2, end: 0);
        },
      ),
    );
  }

  Widget _buildEventsList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📅', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No events nearby',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Community events coming soon',
            style: TextStyle(
              color: AppTheme.ghostWhite.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZonesList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏙️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No active zones',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Public zones coming soon',
            style: TextStyle(
              color: AppTheme.ghostWhite.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbstractMap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AbstractMapSheet(
        ghosts: _nearbyGhosts,
        animationController: _mapAnimationController,
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.ghostAuraGradient : null,
            color: isSelected ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppTheme.ghostWhite,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.ghostWhite,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostCard extends StatelessWidget {
  final NearbyGhost ghost;

  const _GhostCard({required this.ghost});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _getAuraColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _getAuraColor(),
                  _getAuraColor().withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getAuraColor().withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text('⚡', style: TextStyle(fontSize: 28)),
            ),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ghost.displayName,
                      style: const TextStyle(
                        color: AppTheme.ghostWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (ghost.isOnline) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.ghostAuraGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Level ${ghost.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ghost.distance,
                      style: TextStyle(
                        color: AppTheme.ghostWhite.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // View button
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            color: AppTheme.ghostWhite.withOpacity(0.5),
            onPressed: () {
              _showGhostProfile(context, ghost);
            },
          ),
        ],
      ),
    );
  }

  Color _getAuraColor() {
    switch (ghost.auraColor) {
      case 'purple':
        return AppColors.auraStart;
      case 'blue':
        return Colors.blue;
      case 'green':
        return AppColors.success;
      case 'pink':
        return AppColors.particleColor;
      default:
        return AppColors.auraStart;
    }
  }

  void _showGhostProfile(BuildContext context, NearbyGhost ghost) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getAuraColor(),
                        _getAuraColor().withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text('⚡', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ghost.displayName,
                  style: const TextStyle(
                    color: AppTheme.ghostWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Level ${ghost.level} • ${ghost.distance}',
                  style: TextStyle(
                    color: AppTheme.ghostWhite.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Send wave
                        },
                        icon: const Icon(Icons.waving_hand),
                        label: const Text('Wave'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.auraStart,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.ghostWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AbstractMapSheet extends StatelessWidget {
  final List<NearbyGhost> ghosts;
  final AnimationController animationController;

  const _AbstractMapSheet({
    required this.ghosts,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    'Abstract Map',
                    style: TextStyle(
                      color: AppTheme.ghostWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppTheme.ghostWhite,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Map
            Expanded(
              child: Stack(
                children: [
                  // Animated background grid
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: AbstractMapPainter(
                          progress: animationController.value,
                        ),
                      );
                    },
                  ),

                  // Ghost nodes
                  ...ghosts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ghost = entry.value;
                    
                    // Pseudo-random positions
                    final angle = (index * 2.5) % (2 * 3.14159);
                    final radius = 100.0 + (index * 30);
                    
                    return Positioned(
                      left: MediaQuery.of(context).size.width / 2 + 
                            (radius * 0.8) * (index % 2 == 0 ? 1 : -1) - 20,
                      top: MediaQuery.of(context).size.height * 0.4 + 
                           (radius * 0.6) * (index % 3 == 0 ? 1 : -1) - 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.auraStart.withOpacity(0.3),
                          border: Border.all(
                            color: AppColors.auraStart,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text('⚡', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2.seconds, color: Colors.white24);
                  }),

                  // Center (you)
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 30,
                    top: MediaQuery.of(context).size.height * 0.4 - 30,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.ghostAuraGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.auraStart.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('👤', style: TextStyle(fontSize: 30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.auraStart,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'This is an abstract visualization. No exact locations are shown.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AbstractMapPainter extends CustomPainter {
  final double progress;

  AbstractMapPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.auraStart.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw animated grid
    final spacing = 50.0;
    final offset = progress * spacing;

    for (double i = -spacing; i < size.width + spacing; i += spacing) {
      canvas.drawLine(
        Offset(i - offset, 0),
        Offset(i - offset, size.height),
        paint,
      );
    }

    for (double i = -spacing; i < size.height + spacing; i += spacing) {
      canvas.drawLine(
        Offset(0, i - offset),
        Offset(size.width, i - offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AbstractMapPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class NearbyGhost {
  final String id;
  final String displayName;
  final int level;
  final String distance;
  final String auraColor;
  final bool isOnline;

  NearbyGhost({
    required this.id,
    required this.displayName,
    required this.level,
    required this.distance,
    required this.auraColor,
    required this.isOnline,
  });

  factory NearbyGhost.fromJson(Map<String, dynamic> json) {
    return NearbyGhost(
      id: json['id'],
      displayName: json['displayName'] ?? 'Unknown',
      level: json['level'] ?? 1,
      distance: json['distance'] ?? '~',
      auraColor: json['auraColor'] ?? 'purple',
      isOnline: json['isOnline'] ?? false,
    );
  }
}