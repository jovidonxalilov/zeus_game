import 'package:flutter/material.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../achievements/persentation/pages/achievements_screen.dart';
import '../../../game/presentation/widgets/level_selector_screen.dart';
import 'package:flutter/material.dart';
import '../../../inventory/presentation/pages/invertory_screen.dart';
import '../../../settings/presentation/pages/settings_screen.dart';
import '../../../shop/presentation/pages/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

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
    return Column(
      children: [
        // Lightning icon
        Container(
          width: isSmall ? 120 : 160,
          height: isSmall ? 120 : 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFD700),
                const Color(0xFFFF8C00),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.6),
                blurRadius: 40,
                spreadRadius: 15,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/el1_1.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.flash_on,
                  size: 80,
                  color: Colors.white,
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ZEUS title
        Text(
          "ZEUS",
          style: TextStyle(
            fontSize: isSmall ? 56 : 72,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD700),
            shadows: [
              Shadow(
                color: const Color(0xFFFF8C00),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          "Rise of Olympus",
          style: TextStyle(
            fontSize: isSmall ? 16 : 20,
            color: const Color(0xFFF5F5DC),
            letterSpacing: 2,
          ),
        ),
      ],
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