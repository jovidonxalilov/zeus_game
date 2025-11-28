import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/utils/game_utils.dart';

/// Game over dialog
class GameOverDialog extends StatelessWidget {
  final bool isVictory;
  final int score;
  final int stars;
  final int targetScore;
  final VoidCallback onRestart;
  final VoidCallback? onNextLevel;
  final VoidCallback onMenu;
  
  const GameOverDialog({
    super.key,
    required this.isVictory,
    required this.score,
    required this.stars,
    required this.targetScore,
    required this.onRestart,
    this.onNextLevel,
    required this.onMenu,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.goldenBorder,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              isVictory ? 'G\'ALABA!' : 'MAG\'LUBIYAT',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isVictory
                    ? AppConstants.primaryGold
                    : AppConstants.secondaryOrange,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: 24),
            
            // Stars (only for victory)
            if (isVictory)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: AppConstants.primaryGold,
                    size: 48,
                  ).animate(delay: (index * 200).ms).scale(
                        duration: 300.ms,
                        curve: Curves.elasticOut,
                      );
                }),
              ),
            
            const SizedBox(height: 24),
            
            // Score info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.darkPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppConstants.primaryGold.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  _buildScoreRow('Sizning ballingiz', GameUtils.formatScore(score)),
                  const SizedBox(height: 8),
                  _buildScoreRow('Maqsad', GameUtils.formatScore(targetScore)),
                  if (isVictory) ...[
                    const SizedBox(height: 8),
                    _buildScoreRow(
                      'Foiz',
                      '${((score / targetScore) * 100).toInt()}%',
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Menu button
                _buildButton(
                  icon: Icons.home,
                  label: 'Menu',
                  color: AppConstants.darkPurple,
                  onTap: onMenu,
                ),
                
                // Restart button
                _buildButton(
                  icon: Icons.refresh,
                  label: 'Qayta',
                  color: AppConstants.secondaryOrange,
                  onTap: onRestart,
                ),
                
                // Next level button (only for victory)
                if (isVictory && onNextLevel != null)
                  _buildButton(
                    icon: Icons.arrow_forward,
                    label: 'Keyingi',
                    color: AppConstants.primaryGold,
                    onTap: onNextLevel!,
                  ),
              ],
            ),
          ],
        ),
      ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
    );
  }
  
  Widget _buildScoreRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppConstants.primaryGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
    ).animate().shimmer(duration: 2.seconds);
  }
}
