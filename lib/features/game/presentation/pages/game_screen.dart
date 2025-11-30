import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../domain/entities/gem.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/gem_widget.dart';
import '../widgets/score_display.dart';
import '../widgets/moves_counter.dart';
import '../widgets/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({Key? key, this.level = 1}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Gem? selectedGem;
  Gem? dragStartGem;
  Offset dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(InitGameEvent(level: widget.level));
  }

  void _onGemTapped(Gem gem) {
    final currentState = context.read<GameBloc>().state;

    // Don't allow tapping during processing
    if (currentState is GameProcessing) {
      print('⏸️ Processing - please wait...');
      return;
    }

    SoundService().playClick();
    print('\n👆 GEM TAPPED: ${gem.id}');
    print('Selected: ${selectedGem?.id}');

    if (selectedGem == null) {
      // First selection
      print('✅ First selection');
      setState(() => selectedGem = gem);
    } else if (selectedGem!.id == gem.id) {
      // Deselect same gem
      print('❌ Deselecting');
      setState(() => selectedGem = null);
    } else {
      // Second selection - attempt swap
      print('✅ Second gem selected - attempting swap');

      context.read<GameBloc>().add(SwapGemsEvent(
        selectedGem!.row,
        selectedGem!.col,
        gem.row,
        gem.col,
      ));

      setState(() => selectedGem = null);
    }
  }

  void _onDragUpdate(Gem gem, DragUpdateDetails details) {
    if (dragStartGem == null) {
      setState(() {
        dragStartGem = gem;
        selectedGem = gem;
      });
    }

    setState(() {
      dragOffset += details.delta;
    });
  }

  void _onDragEnd(Gem gem) {
    if (dragStartGem == null) return;

    final currentState = context.read<GameBloc>().state;
    if (currentState is GameProcessing) {
      setState(() {
        dragStartGem = null;
        dragOffset = Offset.zero;
        selectedGem = null;
      });
      return;
    }

    // Determine drag direction
    final dx = dragOffset.dx.abs();
    final dy = dragOffset.dy.abs();

    if (dx > 30 || dy > 30) {
      int targetRow = dragStartGem!.row;
      int targetCol = dragStartGem!.col;

      if (dx > dy) {
        // Horizontal swipe
        targetCol += dragOffset.dx > 0 ? 1 : -1;
      } else {
        // Vertical swipe
        targetRow += dragOffset.dy > 0 ? 1 : -1;
      }

      // Bounds check
      if (targetRow >= 0 && targetRow < 7 && targetCol >= 0 && targetCol < 6) {
        print('🖐️ DRAG SWAP: (${dragStartGem!.row}, ${dragStartGem!.col}) → ($targetRow, $targetCol)');

        context.read<GameBloc>().add(SwapGemsEvent(
          dragStartGem!.row,
          dragStartGem!.col,
          targetRow,
          targetCol,
        ));
      }
    }

    setState(() {
      dragStartGem = null;
      dragOffset = Offset.zero;
      selectedGem = null;
    });
  }

  void _showGameOverDialog(BuildContext context, bool isVictory, int score, int targetScore) {
    final gameBloc = context.read<GameBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GameOverDialog(
        isVictory: isVictory,
        score: score,
        targetScore: targetScore,
        onRestart: () {
          Navigator.of(dialogContext).pop();
          gameBloc.add(const RestartGameEvent());
        },
        onNextLevel: () {
          Navigator.of(dialogContext).pop();
          gameBloc.add(InitGameEvent(level: widget.level + 1));
        },
        onMenu: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade900,
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background image
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
                color: Colors.black.withOpacity(0.3),
              ),
            ),

            // Game content
            SafeArea(
              child: BlocConsumer<GameBloc, GameState>(
                listener: (context, state) {
                  if (state is GameWon) {
                    SoundService().playVictory();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _showGameOverDialog(
                        context,
                        true,
                        state.gameState.score,
                        state.gameState.targetScore,
                      );
                    });
                  } else if (state is GameLost) {
                    SoundService().playFailure();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _showGameOverDialog(
                        context,
                        false,
                        state.gameState.score,
                        state.gameState.targetScore,
                      );
                    });
                  }
                },
                builder: (context, state) {
                  print('🎨 UI STATE: ${state.runtimeType}');

                  if (state is GameLoading || state is GameInitial) {
                    return _buildLoading();
                  }

                  if (state is GameReady || state is GameProcessing) {
                    final gameState = state is GameReady
                        ? (state as GameReady).gameState
                        : (state as GameProcessing).gameState;

                    return Column(
                      children: [
                        // Header
                        _buildHeader(gameState.level),

                        const SizedBox(height: 12),

                        // Score display
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ScoreDisplay(
                            score: gameState.score,
                            targetScore: gameState.targetScore,
                            progress: gameState.progress,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Moves
                        MovesCounter(moves: gameState.moves),

                        const SizedBox(height: 16),

                        // Grid
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 6 / 7,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.5),
                                      Colors.purple.shade900.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.yellow.shade700,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(4),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 6,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: 42,
                                  itemBuilder: (context, index) {
                                    final row = index ~/ 6;
                                    final col = index % 6;
                                    final gem = gameState.grid[row][col];

                                    return GemWidget(
                                      gem: gem,
                                      isSelected: selectedGem?.id == gem.id,
                                      onTap: () => _onGemTapped(gem),
                                      onDragUpdate: _onDragUpdate,
                                      onDragEnd: _onDragEnd,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Processing indicator
                        if (state is GameProcessing)
                          Container(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.yellow,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Processing...',
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(height: 40),
                      ],
                    );
                  }

                  if (state is GameError) {
                    return _buildError(state.message);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int level) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.yellow.shade700, Colors.orange.shade700],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'LEVEL $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<GameBloc>().add(const RestartGameEvent());
            },
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.yellow),
          SizedBox(height: 20),
          Text(
            'Loading...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


