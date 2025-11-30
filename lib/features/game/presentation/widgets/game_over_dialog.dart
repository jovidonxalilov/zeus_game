import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final bool isVictory;
  final int score;
  final int targetScore;
  final VoidCallback onRestart;
  final VoidCallback onNextLevel;
  final VoidCallback onMenu;

  const GameOverDialog({
    Key? key,
    required this.isVictory,
    required this.score,
    required this.targetScore,
    required this.onRestart,
    required this.onNextLevel,
    required this.onMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isVictory
                ? [Colors.purple.shade700, Colors.purple.shade900]
                : [Colors.red.shade700, Colors.red.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isVictory ? Colors.yellow : Colors.orange,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (isVictory ? Colors.yellow : Colors.orange)
                  .withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Icon(
                isVictory ? Icons.emoji_events : Icons.cancel,
                color: isVictory ? Colors.yellow : Colors.orange,
                size: 80,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              isVictory ? 'VICTORY!' : 'DEFEAT',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isVictory ? Colors.yellow : Colors.orange,
              ),
            ),

            const SizedBox(height: 24),

            // Score
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Your Score:',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      Text(
                        score.toString(),
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Target:',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      Text(
                        targetScore.toString(),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  icon: Icons.home,
                  label: 'Menu',
                  color: Colors.blue,
                  onTap: onMenu,
                ),
                _buildButton(
                  icon: Icons.refresh,
                  label: 'Restart',
                  color: Colors.orange,
                  onTap: onRestart,
                ),
                if (isVictory)
                  _buildButton(
                    icon: Icons.arrow_forward,
                    label: 'Next',
                    color: Colors.green,
                    onTap: onNextLevel,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
