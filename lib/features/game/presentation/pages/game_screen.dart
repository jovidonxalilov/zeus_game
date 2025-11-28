import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zeus_game/features/game/presentation/widgets/tutorial_dialog.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/gem.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart' as bloc_state;
import '../widgets/gem_widget.dart';
import '../widgets/game_header.dart';
import '../widgets/zeus_power_bar.dart';
import '../widgets/game_over_dialog.dart';

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
            
            // Game content
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
                        // Header with padding
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: GameHeader(
                            score: gameState.score,
                            targetScore: gameState.targetScore,
                            moves: gameState.moves,
                            level: level.id,
                            onPause: () => context.read<GameBloc>().add(const PauseGameEvent()),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Game Grid - larger and centered
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildGameGrid(gameState.grid),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Zeus Powers with padding
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        
                        const SizedBox(height: 8),
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
            
            // Help button (floating)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFFFFD700),
                  onPressed: _showTutorial,
                  child: const Icon(
                    Icons.help_outline,
                    color: Color(0xFF1A1A1A),
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
  
  Widget _buildGameGrid(List<List<Gem>> grid) {
    return AspectRatio(
      aspectRatio: AppConstants.gridColumns / AppConstants.gridRows,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppConstants.gridColumns,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemCount: AppConstants.gridRows * AppConstants.gridColumns,
          itemBuilder: (context, index) {
            final row = index ~/ AppConstants.gridColumns;
            final col = index % AppConstants.gridColumns;
            final gem = grid[row][col];
            
            return GemWidget(
              gem: gem,
              isSelected: selectedGem?.id == gem.id,
              onTap: () => _onGemTapped(gem),
            );
          },
        ),
      ),
    );
  }
  
  void _onGemTapped(Gem gem) {
    if (selectedGem == null) {
      setState(() {
        selectedGem = gem;
      });
    } else {
      // Try to swap
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