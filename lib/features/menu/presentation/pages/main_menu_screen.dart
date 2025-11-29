import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../map/presentation/pages/map_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700; // Kichik ekranlar (iPhone SE, eski Android)

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B0082), Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_1.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTitle(isSmall),

                      SizedBox(height: isSmall ? 40 : 60),

                      _buildMenuButton(
                        context: context,
                        icon: Icons.play_arrow,
                        label: "O'YNASH",
                        color: const Color(0xFFFFD700),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MapScreen()),
                          );
                        },
                        delay: 0,
                      ),

                      const SizedBox(height: 16),

                      _buildMenuButton(
                        context: context,
                        icon: Icons.map,
                        label: "XARITA",
                        color: const Color(0xFF00BFFF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MapScreen()),
                          );
                        },
                        delay: 100,
                      ),

                      const SizedBox(height: 16),

                      _buildMenuButton(
                        context: context,
                        icon: Icons.emoji_events,
                        label: "YUTUQLAR",
                        color: const Color(0xFFFF8C00),
                        onTap: () => _showComingSoon(context),
                        delay: 200,
                      ),

                      const SizedBox(height: 16),

                      _buildMenuButton(
                        context: context,
                        icon: Icons.settings,
                        label: "SOZLAMALAR",
                        color: const Color(0xFFB0B0B0),
                        onTap: () => _showComingSoon(context),
                        delay: 300,
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(bool small) {
    return Column(
      children: [
        Container(
          width: small ? 110 : 150,
          height: small ? 110 : 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
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
              errorBuilder: (_, __, ___) => const Icon(Icons.flash_on, size: 70),
            ),
          ),
        )
            .animate()
            .scale(duration: 800.ms, curve: Curves.elasticOut)
            .shimmer(duration: 2.seconds, delay: 800.ms),

        const SizedBox(height: 20),

        Text(
          "ZEUS",
          style: TextStyle(
            fontSize: small ? 55 : 72,
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
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),

        const SizedBox(height: 8),

        Text(
          "Rise of Olympus",
          style: TextStyle(
            fontSize: small ? 17 : 20,
            color: const Color(0xFFF5F5DC),
            letterSpacing: 2,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
      ],
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 450),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ).animate(delay: delay.ms)
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.3)
            .shimmer(duration: 2.seconds),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF4B0082),
        title: const Text(
          "Tez orada",
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        content: const Text(
          "Bu funksiya tez orada qo'shiladi!",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(color: Color(0xFFFFD700)),
            ),
          )
        ],
      ),
    );
  }
}
