import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/utils/game_utils.dart';

/// Game header widget
class GameHeader extends StatelessWidget {
  final int score;
  final int targetScore;
  final int moves;
  final int level;
  final VoidCallback onPause;
  
  const GameHeader({
    super.key,
    required this.score,
    required this.targetScore,
    required this.moves,
    required this.level,
    required this.onPause,
  });
  
  @override
  Widget build(BuildContext context) {
    final progress = (score / targetScore).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.marblePanel,
      child: Column(
        children: [
          // Top row: Level and Pause
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Level
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppConstants.primaryGold, width: 2),
                ),
                child: Text(
                  'Daraja $level',
                  style: TextStyle(
                    color: AppConstants.primaryGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Pause button
              IconButton(
                onPressed: onPause,
                icon: Icon(
                  Icons.pause_circle_outline,
                  color: AppConstants.primaryGold,
                  size: 32,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Score and Target
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoCard(
                label: 'Ball',
                value: GameUtils.formatScore(score),
                icon: Icons.star,
                color: AppConstants.primaryGold,
              ),
              _buildInfoCard(
                label: 'Harakatlar',
                value: moves.toString(),
                icon: Icons.swap_horiz,
                color: moves > 10 ? AppConstants.electricBlue : AppConstants.secondaryOrange,
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Maqsad: ${GameUtils.formatScore(targetScore)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: AppConstants.primaryGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: AppConstants.darkPurple.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppConstants.primaryGold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, duration: 500.ms);
  }
  
  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
