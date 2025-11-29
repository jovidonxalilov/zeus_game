import 'package:flutter/material.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../achievements/persentation/pages/achievements_screen.dart';
import '../../../game/presentation/widgets/level_selector_screen.dart';
import 'package:flutter/material.dart';
import '../../../inventory/presentation/pages/invertory_screen.dart';
import '../../../settings/presentation/pages/settings_screen.dart';
import '../../../shop/presentation/pages/shop_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4B0082),
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_1.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

            // Dark overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),

            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with Zeus lightning
                      _buildLogo(isSmall),

                      SizedBox(height: isSmall ? 40 : 60),

                      // Play button
                      AnimatedCard(
                        delay: 100,
                        child: _buildButton(
                          context: context,
                          icon: Icons.play_arrow,
                          label: "PLAY",
                          color: const Color(0xFF00FF00),
                          onTap: () {
                            SoundService().playClick();
                            Navigator.of(context).push(
                              PageTransitions.slideFromRight(
                                const LevelSelectorScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Levels button
                      AnimatedCard(
                        delay: 200,
                        child: _buildButton(
                          context: context,
                          icon: Icons.format_list_numbered,
                          label: "LEVELS",
                          color: const Color(0xFF00BFFF),
                          onTap: () {
                            SoundService().playClick();
                            Navigator.of(context).push(
                              PageTransitions.slideFromRight(
                                const LevelSelectorScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Achievements button
                      AnimatedCard(
                        delay: 300,
                        child: _buildButton(
                          context: context,
                          icon: Icons.emoji_events,
                          label: "ACHIEVEMENTS",
                          color: const Color(0xFFFFD700),
                          onTap: () {
                            SoundService().playClick();
                            Navigator.of(context).push(
                              PageTransitions.fadeIn(
                                const AchievementsScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Inventory button
                      AnimatedCard(
                        delay: 400,
                        child: _buildButton(
                          context: context,
                          icon: Icons.inventory,
                          label: "INVENTORY",
                          color: const Color(0xFF9C27B0),
                          onTap: () {
                            SoundService().playClick();
                            Navigator.of(context).push(
                              PageTransitions.fadeIn(
                                const InventoryScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Shop button
                      AnimatedCard(
                        delay: 500,
                        child: _buildButton(
                          context: context,
                          icon: Icons.shopping_bag,
                          label: "SHOP",
                          color: const Color(0xFFE91E63),
                          onTap: () {
                            SoundService().playClick();
                            Navigator.of(context).push(
                              PageTransitions.fadeIn(
                                const ShopScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Settings button
                      AnimatedCard(
                        delay: 600,
                        child: _buildButton(
                          context: context,
                          icon: Icons.settings,
                          label: "SETTINGS",
                          color: const Color(0xFFB0B0B0),
                          onTap: () {
                            SoundService().playClick();
                            Navigator.of(context).push(
                              PageTransitions.slideFromBottom(
                                const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(bool isSmall) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Column(
          children: [
            // Animated Lightning icon with beautiful effects
            Transform.rotate(
              angle: _rotationAnimation.value,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: isSmall ? 140 : 180,
                  height: isSmall ? 140 : 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFFFFF),
                        const Color(0xFFFFD700),
                        const Color(0xFFFF8C00),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      // Outer glow
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.8),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                      // Inner bright glow
                      BoxShadow(
                        color: const Color(0xFFFFFFFF).withOpacity(0.6),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      // Pulsing glow
                      BoxShadow(
                        color: const Color(0xFFFF8C00).withOpacity(_pulseAnimation.value - 0.85),
                        blurRadius: 80,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Lightning image
                      ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFFFFFF).withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/el1_1.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) {
                              return Center(
                                child: Icon(
                                  Icons.flash_on,
                                  size: isSmall ? 70 : 90,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Shine overlay
                      Positioned.fill(
                        child: ClipOval(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                                center: const Alignment(-0.4, -0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ZEUS title with enhanced shadow
            Text(
              "ZEUS",
              style: TextStyle(
                fontSize: isSmall ? 60 : 76,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFD700),
                shadows: [
                  Shadow(
                    color: const Color(0xFFFF8C00),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                  Shadow(
                    color: Colors.black,
                    offset: const Offset(0, 6),
                    blurRadius: 12,
                  ),
                  Shadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    offset: const Offset(0, 0),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle with glow
            Text(
              "Rise of Olympus",
              style: TextStyle(
                fontSize: isSmall ? 17 : 22,
                color: const Color(0xFFF5F5DC),
                letterSpacing: 3,
                fontWeight: FontWeight.w300,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D1B4E),
        title: const Text(
          'SOZLAMALAR',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                SoundService().isMuted
                    ? Icons.volume_off
                    : Icons.volume_up,
                color: const Color(0xFFFFD700),
              ),
              title: Text(
                SoundService().isMuted ? 'Ovoz: O\'CHIRILGAN' : 'Ovoz: YONIQ',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                SoundService().toggleMute();
                Navigator.of(context).pop();
                _showSettings(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D1B4E),
        title: const Text(
          'TEZ ORADA',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        content: const Text(
          "Bu funksiya tez orada qo'shiladi!",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }
}
