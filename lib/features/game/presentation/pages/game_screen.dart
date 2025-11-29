import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/gem.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart' as bloc_state;
import '../widgets/game_header.dart';
import '../widgets/gem_widget.dart';
import '../widgets/zeus_power_bar.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/tutorial_dialog.dart';

/// Main game screen
class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Gem? selectedGem;
  bool _tutorialShown = false;

  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(InitializeGameEvent(widget.level));

    // Show tutorial after a short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_tutorialShown && widget.level == 1) {
        _tutorialShown = true;
        _showTutorial();
      }
    });
  }

  void _showTutorial() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const TutorialDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF4B0082),
              const Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background image with error handling
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_1.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Dark overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

            // Game content with proper SafeArea
            SafeArea(
              child: BlocConsumer<GameBloc, bloc_state.GameBlocState>(
                listener: (context, state) {
                  if (state is bloc_state.GameOver) {
                    _showGameOverDialog(context, state);
                  }
                },
                builder: (context, state) {
                  if (state is bloc_state.GameLoading) {
                    return _buildLoading();
                  }

                  if (state is bloc_state.GamePlaying || state is bloc_state.GameProcessing) {
                    final gameState = state is bloc_state.GamePlaying
                        ? (state as bloc_state.GamePlaying).gameState
                        : (state as bloc_state.GameProcessing).gameState;

                    final level = state is bloc_state.GamePlaying
                        ? (state as bloc_state.GamePlaying).level
                        : (state as bloc_state.GameProcessing).level;

                    return Column(
                      children: [
                        // Header - compact but clear
                        Container(
                          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: GameHeader(
                            score: gameState.score,
                            targetScore: gameState.targetScore,
                            moves: gameState.moves,
                            level: level.id,
                            onPause: () => context.read<GameBloc>().add(const PauseGameEvent()),
                          ),
                        ),

                        // Game Grid - FULL 7 ROWS VISIBLE
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate grid dimensions
                              final availableWidth = constraints.maxWidth - 32;
                              final availableHeight = constraints.maxHeight - 16;

                              // Grid aspect ratio: 6 columns / 7 rows = 0.857
                              final aspectRatio = AppConstants.gridColumns / AppConstants.gridRows;

                              // Calculate sizes
                              double gridWidth;
                              double gridHeight;

                              // Try width-based calculation
                              gridHeight = availableWidth / aspectRatio;

                              if (gridHeight <= availableHeight) {
                                // Width is limiting - use full width
                                gridWidth = availableWidth;
                              } else {
                                // Height is limiting - use full height
                                gridHeight = availableHeight;
                                gridWidth = gridHeight * aspectRatio;
                              }

                              return Center(
                                child: Container(
                                  width: gridWidth,
                                  height: gridHeight,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Color(0xFF1A0033).withOpacity(0.8),
                                      ],
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
                                        color: Color(0xFFFFD700).withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(4),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: AppConstants.gridColumns,
                                      mainAxisSpacing: 6,
                                      crossAxisSpacing: 6,
                                      childAspectRatio: 1.0,
                                    ),
                                    itemCount: AppConstants.gridRows * AppConstants.gridColumns,
                                    itemBuilder: (context, index) {
                                      final row = index ~/ AppConstants.gridColumns;
                                      final col = index % AppConstants.gridColumns;
                                      final gem = gameState.grid[row][col];

                                      return GemWidgetSimple(
                                        gem: gem,
                                        isSelected: selectedGem?.id == gem.id,
                                        onTap: () => _onGemTapped(gem),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Zeus Powers - fixed at bottom
                        Container(
                          margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                          child: ZeusPowerBar(
                            energy: gameState.energy,
                            maxEnergy: gameState.maxEnergy,
                            onPowerUsed: (power, row, col) {
                              context.read<GameBloc>().add(UseZeusPowerEvent(
                                power: power,
                                targetRow: row,
                                targetCol: col,
                              ));
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  if (state is bloc_state.GamePaused) {
                    return _buildPausedScreen(context, state);
                  }

                  if (state is bloc_state.GameError) {
                    return _buildError(state.message);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),

            // Help button (floating) - repositioned
            Positioned(
              top: 60,
              right: 20,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showTutorial,
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Color(0xFF1A1A1A),
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFFFD700),
          ),
          const SizedBox(height: 20),
          Text(
            'Yuklanmoqda...',
            style: TextStyle(
              color: const Color(0xFFFFD700),
              fontSize: 18,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }


  void _onGemTapped(Gem gem) {
    // Don't allow tapping during processing
    final currentState = context.read<GameBloc>().state;
    if (currentState is bloc_state.GameProcessing) {
      return;
    }

    if (selectedGem == null) {
      // First selection
      setState(() {
        selectedGem = gem;
      });
    } else {
      // Check if gems are adjacent (not diagonal!)
      final rowDiff = (selectedGem!.row - gem.row).abs();
      final colDiff = (selectedGem!.column - gem.column).abs();
      final isAdjacent = (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);

      if (!isAdjacent) {
        // Show visual feedback for invalid move
        _showInvalidMoveIndicator();
        // Deselect current gem
        setState(() {
          selectedGem = null;
        });
        return;
      }

      // Valid swap - send event
      context.read<GameBloc>().add(SwapGemsEvent(
        fromRow: selectedGem!.row,
        fromCol: selectedGem!.column,
        toRow: gem.row,
        toCol: gem.column,
      ));

      setState(() {
        selectedGem = null;
      });
    }
  }

  void _showInvalidMoveIndicator() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Faqat qo\'shni!',
                style: TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF4B0082),
        duration: Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 100, left: 20, right: 20),
      ),
    );
  }

  Widget _buildPausedScreen(BuildContext context, bloc_state.GamePaused state) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF4B0082).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TO\'XTATILDI',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.read<GameBloc>().add(const ResumeGameEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF1A1A1A),
                minimumSize: const Size(200, 50),
              ),
              child: const Text('Davom ettirish'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.read<GameBloc>().add(const RestartGameEvent()),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFFFFD700), width: 2),
                minimumSize: const Size(200, 50),
              ),
              child: const Text('Qaytadan boshlash'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Menuga qaytish'),
            ),
          ],
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: const Color(0xFFFF8C00),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Orqaga'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, bloc_state.GameOver state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        isVictory: state.isVictory,
        score: state.finalScore,
        stars: state.stars,
        targetScore: state.level.targetScore,
        onRestart: () {
          Navigator.of(context).pop();
          context.read<GameBloc>().add(const RestartGameEvent());
        },
        onNextLevel: state.isVictory
            ? () {
          Navigator.of(context).pop();
          context.read<GameBloc>().add(InitializeGameEvent(state.level.id + 1));
        }
            : null,
        onMenu: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}