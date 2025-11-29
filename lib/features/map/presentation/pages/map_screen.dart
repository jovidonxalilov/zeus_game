import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../game/domain/entities/level.dart';
import '../../../game/presentation/pages/game_screen.dart';
import '../../../game/presentation/bloc/game_bloc.dart';

/// Map screen - level selection
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = LevelData.allLevels;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.darkPurple,
              AppConstants.shadowBlack,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Levels grid
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    return _buildLevelCard(context, level, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.marblePanel,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              color: AppConstants.primaryGold,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'OLIMP XARITASI',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryGold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, duration: 500.ms);
  }

  Widget _buildLevelCard(BuildContext context, Level level, int index) {
    final isLocked = level.status == LevelStatus.locked;
    final isCompleted = level.status == LevelStatus.completed;

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => GameBloc(),
                    child: GameScreen(level: level.id),
                  ),
                ),
              );
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked
              ? AppConstants.darkPurple.withOpacity(0.3)
              : AppConstants.darkPurple.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLocked
                ? AppConstants.darkPurple
                : AppConstants.primaryGold.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: AppConstants.primaryGold.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Row(
          children: [
            // Level number
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLocked
                    ? AppConstants.darkPurple
                    : Color(level.difficultyColor).withOpacity(0.3),
                border: Border.all(
                  color: isLocked
                      ? AppConstants.darkPurple
                      : Color(level.difficultyColor),
                  width: 3,
                ),
              ),
              child: Center(
                child: isLocked
                    ? Icon(
                        Icons.lock,
                        color: AppConstants.darkPurple,
                        size: 32,
                      )
                    : Text(
                        '${level.id}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(level.difficultyColor),
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 16),

            // Level info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.white38 : AppConstants.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isLocked ? Colors.white24 : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.star,
                        value: '${level.targetScore}',
                        color: AppConstants.primaryGold,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.swap_horiz,
                        value: '${level.moves}',
                        color: AppConstants.electricBlue,
                      ),
                      if (level.hasBoss) ...[
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.person,
                          value: level.bossName!,
                          color: AppConstants.secondaryOrange,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Stars
            if (isCompleted)
              Column(
                children: [
                  Row(
                    children: List.generate(3, (i) {
                      return Icon(
                        i < level.stars ? Icons.star : Icons.star_border,
                        color: AppConstants.primaryGold,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${level.highScore}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConstants.primaryGold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      )
          .animate(delay: (index * 100).ms)
          .fadeIn(duration: 500.ms)
          .slideX(begin: -0.2, duration: 500.ms),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
