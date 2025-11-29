import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/audio_manager.dart';
import '../bloc/game_bloc.dart';
import '../pages/game_screen.dart';


class LevelSelectorScreen extends StatelessWidget {
  const LevelSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(//
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
                color: Colors.black.withOpacity(0.4),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
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
                          'DARAJANI TANLANG',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Level grid
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxHeight;

                        // Karta nisbatini ekranga qarab avtomatik moslash
                        final ratio = width / (height * 0.95); // juda mos tushadi

                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: ratio.clamp(0.60, 0.90),
                            ),
                            itemCount: 9,
                            itemBuilder: (context, index) {
                              final level = index + 1;
                              return _buildLevelCard(context, level);
                            },
                          ),
                        );
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

  Widget _buildLevelCard(BuildContext context, int level) {
    final colors = _getLevelColors(level);

    return GestureDetector(
      onTap: () {
        SoundService().playClick();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => GameBloc(),
              child: GameScreen(level: level),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFD700),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Level number
            Text(
              level.toString(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Level name
            Text(
              _getLevelName(level),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            // Target score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Color(0xFFFFD700),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${1000 + (level - 1) * 500}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  List<Color> _getLevelColors(int level) {
    switch (level) {
      case 1:
        return [const Color(0xFF00C853), const Color(0xFF1B5E20)];
      case 2:
        return [const Color(0xFF2196F3), const Color(0xFF0D47A1)];
      case 3:
        return [const Color(0xFFFF9800), const Color(0xFFE65100)];
      case 4:
        return [const Color(0xFF9C27B0), const Color(0xFF4A148C)];
      case 5:
        return [const Color(0xFFE91E63), const Color(0xFF880E4F)];
      case 6:
        return [const Color(0xFF00BCD4), const Color(0xFF006064)];
      case 7:
        return [const Color(0xFFFF5722), const Color(0xFFBF360C)];
      case 8:
        return [const Color(0xFF673AB7), const Color(0xFF311B92)];
      case 9:
        return [const Color(0xFFFFD700), const Color(0xFFFF6F00)];
      default:
        return [const Color(0xFF2196F3), const Color(0xFF0D47A1)];
    }
  }

  String _getLevelName(int level) {
    switch (level) {
      case 1:
        return 'BOSHLANG\'ICH';
      case 2:
        return 'OSON';
      case 3:
        return 'O\'RTACHA';
      case 4:
        return 'QIYIN';
      case 5:
        return 'JUDA QIYIN';
      case 6:
        return 'MURAKKAB';
      case 7:
        return 'EKSPERT';
      case 8:
        return 'MASTER';
      case 9:
        return 'OLIMP';
      default:
        return 'LEVEL $level';
    }
  }
}