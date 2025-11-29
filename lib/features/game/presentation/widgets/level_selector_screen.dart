import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../bloc/game_bloc.dart';
import '../pages/game_screen.dart';


class LevelSelectorScreen extends StatelessWidget {
  const LevelSelectorScreen({Key? key}) : super(key: key);

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
                          'SELECT LEVEL',
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
                        // Calculate responsive sizing to prevent overflow
                        final availableHeight = constraints.maxHeight;
                        final availableWidth = constraints.maxWidth;

                        // Calculate card size to fit perfectly
                        final spacing = 12.0;
                        final horizontalPadding = 20.0;
                        final cardWidth = (availableWidth - horizontalPadding * 2 - spacing * 2) / 3;

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: 20,
                            bottom: 40, // Extra bottom padding to prevent overflow
                          ),
                          child: Column(
                            children: [
                              // Grid with 9 levels
                              Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: List.generate(9, (index) {
                                  final level = index + 1;
                                  return SizedBox(
                                    width: cardWidth,
                                    height: cardWidth * 1.3, // Aspect ratio
                                    child: AnimatedCard(
                                      delay: index * 80,
                                      child: _buildLevelCard(context, level),
                                    ),
                                  );
                                }),
                              ),
                            ],
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
          PageTransitions.scaleIn(
            BlocProvider(
              create: (_) => GameBloc(),
              child: GameScreen(level: level),
            ),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, box) {
          final cardW = box.maxWidth;
          final cardH = box.maxHeight;

          // Responsive sizing
          final numberSize = cardW * 0.33;
          final titleSize = cardW * 0.10;
          final scoreSize = cardW * 0.085;
          final starSize = cardW * 0.09;

          return Container(
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
                // LEVEL NUMBER
                Text(
                  level.toString(),
                  style: TextStyle(
                    fontSize: numberSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: cardH * 0.02),

                // LEVEL NAME
                Text(
                  _getLevelName(level),
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: cardH * 0.01),

                // TARGET SCORE
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: cardW * 0.06,
                    vertical: cardH * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: const Color(0xFFFFD700),
                        size: starSize,
                      ),
                      SizedBox(width: cardW * 0.02),
                      Text(
                        '${1000 + (level - 1) * 500}',
                        style: TextStyle(
                          fontSize: scoreSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
        return 'BEGINNER';
      case 2:
        return 'EASY';
      case 3:
        return 'MEDIUM';
      case 4:
        return 'HARD';
      case 5:
        return 'VERY HARD';
      case 6:
        return 'EXPERT';
      case 7:
        return 'PRO';
      case 8:
        return 'MASTER';
      case 9:
        return 'OLYMPUS';
      default:
        return 'LEVEL $level';
    }
  }
}