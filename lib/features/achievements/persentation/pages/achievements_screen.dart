import 'package:flutter/material.dart';
import '../../../../core/utils/audio_manager.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            // Background
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
                color: Colors.black.withOpacity(0.5),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context),

                  // Achievements list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _achievements.length,
                      itemBuilder: (context, index) {
                        return _buildAchievementCard(_achievements[index]);
                      },
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              SoundService().playClick();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFFFD700),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'ACHIEVEMENTS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: achievement.unlocked
              ? [
            Colors.purple.shade700.withOpacity(0.8),
            Colors.purple.shade900.withOpacity(0.9),
          ]
              : [
            Colors.grey.shade800.withOpacity(0.6),
            Colors.grey.shade900.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.unlocked
              ? const Color(0xFFFFD700)
              : Colors.grey.shade700,
          width: 2,
        ),
        boxShadow: achievement.unlocked
            ? [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.3),
            blurRadius: 10,
          ),
        ]
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: achievement.unlocked
                    ? [Colors.yellow.shade600, Colors.orange.shade600]
                    : [Colors.grey.shade600, Colors.grey.shade800],
              ),
              boxShadow: achievement.unlocked
                  ? [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ]
                  : null,
            ),
            child: Icon(
              achievement.icon,
              size: 32,
              color: achievement.unlocked ? Colors.white : Colors.grey.shade400,
            ),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: achievement.unlocked
                        ? const Color(0xFFFFD700)
                        : Colors.grey.shade400,
                  ),
                ),

                const SizedBox(height: 4),

                // Description
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: achievement.unlocked
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 8),

                // Progress
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: achievement.progress,
                          minHeight: 8,
                          backgroundColor: Colors.black.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            achievement.unlocked
                                ? Colors.green
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${achievement.current}/${achievement.target}',
                      style: TextStyle(
                        fontSize: 12,
                        color: achievement.unlocked
                            ? const Color(0xFFFFD700)
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Checkmark if unlocked
          if (achievement.unlocked)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  static final List<Achievement> _achievements = [
    Achievement(
      title: 'Thunder Lord',
      description: 'Use 100 lightning strikes',
      icon: Icons.flash_on,
      current: 100,
      target: 100,
      unlocked: true,
    ),
    Achievement(
      title: 'Storm Master',
      description: 'Use 50 ultimate abilities',
      icon: Icons.storm,
      current: 50,
      target: 50,
      unlocked: true,
    ),
    Achievement(
      title: 'Temple Savior',
      description: 'Clear 25 temples',
      icon: Icons.account_balance,
      current: 25,
      target: 25,
      unlocked: true,
    ),
    Achievement(
      title: 'Gem Collector',
      description: 'Collect 1000 gems',
      icon: Icons.diamond,
      current: 756,
      target: 1000,
      unlocked: false,
    ),
    Achievement(
      title: 'Level Master',
      description: 'Complete all levels',
      icon: Icons.emoji_events,
      current: 7,
      target: 9,
      unlocked: false,
    ),
    Achievement(
      title: 'Combo King',
      description: 'Get 10x combo',
      icon: Icons.auto_awesome,
      current: 8,
      target: 10,
      unlocked: false,
    ),
    Achievement(
      title: 'Quick Winner',
      description: 'Win in 5 moves',
      icon: Icons.speed,
      current: 0,
      target: 1,
      unlocked: false,
    ),
    Achievement(
      title: 'Olympus Hero',
      description: 'Reach 50,000 points',
      icon: Icons.stars,
      current: 23450,
      target: 50000,
      unlocked: false,
    ),
  ];
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final int current;
  final int target;
  final bool unlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.current,
    required this.target,
    required this.unlocked,
  });

  double get progress => (current / target).clamp(0.0, 1.0);
}