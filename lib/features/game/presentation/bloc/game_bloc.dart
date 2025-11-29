import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../domain/entities/gem.dart';
import '../../domain/model/state_model.dart';
import 'game_event.dart';
import 'game_state.dart';

const int ROWS = 7;
const int COLS = 6;

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(const GameInitial()) {
    on<InitGameEvent>(_onInit);
    on<SwapGemsEvent>(_onSwap);
    on<ProcessMatchesEvent>(_onProcessMatches);
    on<RestartGameEvent>(_onRestart);
  }

  Future<void> _onInit(InitGameEvent event, Emitter<GameState> emit) async {
    emit(const GameLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    print('🎮 INITIALIZING GAME - Level ${event.level}');

    // Generate grid without initial matches - MULTIPLE ATTEMPTS
    var grid = _generateGrid();
    int attempts = 0;
    const maxAttempts = 50;

    while (_findMatches(grid).isNotEmpty && attempts < maxAttempts) {
      grid = _generateGrid();
      attempts++;
      print('🔄 Regenerating grid (attempt $attempts) - had matches');
    }

    if (attempts == maxAttempts) {
      print('⚠️ Max attempts reached, manually fixing matches');
      // If still has matches after max attempts, replace matched gems
      final matches = _findMatches(grid);
      for (final match in matches) {
        grid[match.row][match.col] = Gem(
          id: '${match.row}_${match.col}',
          type: _getRandomNonMatchingType(grid, match.row, match.col),
          row: match.row,
          col: match.col,
        );
      }
    }

    final gameState = GameStateModel(
      grid: grid,
      score: 0,
      moves: 30,
      targetScore: 1000 + (event.level - 1) * 500,
      level: event.level,
    );

    print('✅ Game initialized: ${ROWS}x$COLS grid, Target: ${gameState.targetScore}');
    emit(GameReady(gameState));
  }

  GemType _getRandomNonMatchingType(List<List<Gem>> grid, int row, int col) {
    final avoid = <GemType>{};

    // Check horizontal neighbors
    if (col >= 2) {
      if (grid[row][col - 1].type == grid[row][col - 2].type) {
        avoid.add(grid[row][col - 1].type);
      }
    }

    // Check vertical neighbors
    if (row >= 2) {
      if (grid[row - 1][col].type == grid[row - 2][col].type) {
        avoid.add(grid[row - 1][col].type);
      }
    }

    // Get available types
    final available = GemType.values.where((t) => !avoid.contains(t)).toList();
    return available[Random().nextInt(available.length)];
  }

  Future<void> _onSwap(
      SwapGemsEvent event,
      Emitter<GameState> emit,
      ) async {
    if (state is! GameReady) {
      print('❌ Can\'t swap - state is ${state.runtimeType}');
      return;
    }

    final current = (state as GameReady).gameState;

    if (current.isProcessing) {
      print('❌ Already processing');
      return;
    }

    print('\n🔄 SWAP REQUEST');
    print('From: (${event.row1}, ${event.col1})');
    print('To: (${event.row2}, ${event.col2})');

    // Check adjacent
    final rowDiff = (event.row1 - event.row2).abs();
    final colDiff = (event.col1 - event.col2).abs();
    final isAdjacent = (rowDiff == 1 && colDiff == 0) ||
        (rowDiff == 0 && colDiff == 1);

    if (!isAdjacent) {
      print('❌ NOT ADJACENT!');
      return;
    }

    print('✅ Adjacent - processing swap...');

    // Copy grid
    final grid = _copyGrid(current.grid);

    // Perform swap
    final temp = grid[event.row1][event.col1];
    grid[event.row1][event.col1] = grid[event.row2][event.col2].copyWith(
      row: event.row1,
      col: event.col1,
      isAnimating: true,
    );
    grid[event.row2][event.col2] = temp.copyWith(
      row: event.row2,
      col: event.col2,
      isAnimating: true,
    );

    // Show swap animation
    emit(GameReady(current.copyWith(grid: grid, isProcessing: true)));
    await Future.delayed(const Duration(milliseconds: 300));

    // Check matches
    final matches = _findMatches(grid);
    print('🔍 Matches found: ${matches.length}');

    if (matches.isEmpty) {
      print('❌ No matches - swapping back');

      // Swap back
      final temp2 = grid[event.row1][event.col1];
      grid[event.row1][event.col1] = grid[event.row2][event.col2].copyWith(
        row: event.row1,
        col: event.col1,
        isAnimating: false,
      );
      grid[event.row2][event.col2] = temp2.copyWith(
        row: event.row2,
        col: event.col2,
        isAnimating: false,
      );

      emit(GameReady(current.copyWith(grid: grid, isProcessing: false)));
      return;
    }

    // Valid move - decrease moves
    final newMoves = current.moves - 1;
    print('✅ Valid move! Moves left: $newMoves');

    // Clear animation flags
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS; c++) {
        if (grid[r][c].isAnimating) {
          grid[r][c] = grid[r][c].copyWith(isAnimating: false);
        }
      }
    }

    emit(GameReady(current.copyWith(
      grid: grid,
      moves: newMoves,
      isProcessing: true,
    )));

    // Process matches
    add(const ProcessMatchesEvent());
  }

  Future<void> _onProcessMatches(
      ProcessMatchesEvent event,
      Emitter<GameState> emit,
      ) async {
    if (state is! GameReady) return;

    var current = (state as GameReady).gameState;
    var grid = _copyGrid(current.grid);
    var totalScore = current.score;
    var combo = 1;

    bool foundMatches = true;

    while (foundMatches) {
      final matches = _findMatches(grid);

      if (matches.isEmpty) {
        foundMatches = false;
        break;
      }

      print('💥 Processing ${matches.length} matches (Combo x$combo)');

      // Play match sound
      SoundService().playMatch();

      // Mark matched gems
      for (final match in matches) {
        grid[match.row][match.col] = match.copyWith(isMatched: true);
      }

      // Calculate score
      final points = matches.length * 100 * combo;
      totalScore += points;
      print('✨ +$points points! Total: $totalScore');

      // Show match animation
      emit(GameProcessing(current.copyWith(grid: grid, score: totalScore)));
      await Future.delayed(const Duration(milliseconds: 400));

      // Remove matched and drop gems
      _processGravity(grid);

      // Play fall sound
      SoundService().playFall();

      // Show falling animation
      emit(GameProcessing(current.copyWith(grid: grid, score: totalScore)));
      await Future.delayed(const Duration(milliseconds: 400));

      combo++;
    }

    // Final state
    final finalState = current.copyWith(
      grid: grid,
      score: totalScore,
      isProcessing: false,
    );

    // Check win/lose conditions
    if (finalState.isWon) {
      print('🎉 VICTORY! Score: $totalScore');
      emit(GameWon(finalState));
    } else if (finalState.isLost) {
      print('💔 GAME OVER! Score: $totalScore');
      emit(GameLost(finalState));
    } else {
      emit(GameReady(finalState));
    }
  }

  void _onRestart(RestartGameEvent event, Emitter<GameState> emit) {
    final level = state is GameReady
        ? (state as GameReady).gameState.level
        : state is GameWon
        ? (state as GameWon).gameState.level
        : state is GameLost
        ? (state as GameLost).gameState.level
        : 1;

    add(InitGameEvent(level: level));
  }

  List<List<Gem>> _generateGrid() {
    return List.generate(
      ROWS,
          (r) => List.generate(
        COLS,
            (c) => Gem(
          id: '${r}_$c',
          type: _randomGemType(),
          row: r,
          col: c,
        ),
      ),
    );
  }

  List<List<Gem>> _copyGrid(List<List<Gem>> grid) {
    return grid.map((row) => row.map((gem) => gem).toList()).toList();
  }

  GemType _randomGemType() {
    return GemType.values[Random().nextInt(GemType.values.length)];
  }

  List<Gem> _findMatches(List<List<Gem>> grid) {
    final Set<Gem> matches = {};

    // Check horizontal
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS - 2; c++) {
        final g1 = grid[r][c];
        final g2 = grid[r][c + 1];
        final g3 = grid[r][c + 2];

        if (!g1.isMatched && !g2.isMatched && !g3.isMatched &&
            g1.type == g2.type && g2.type == g3.type) {
          matches.addAll([g1, g2, g3]);
        }
      }
    }

    // Check vertical
    for (int c = 0; c < COLS; c++) {
      for (int r = 0; r < ROWS - 2; r++) {
        final g1 = grid[r][c];
        final g2 = grid[r + 1][c];
        final g3 = grid[r + 2][c];

        if (!g1.isMatched && !g2.isMatched && !g3.isMatched &&
            g1.type == g2.type && g2.type == g3.type) {
          matches.addAll([g1, g2, g3]);
        }
      }
    }

    return matches.toList();
  }

  void _processGravity(List<List<Gem>> grid) {
    // Drop existing gems
    for (int c = 0; c < COLS; c++) {
      int writeRow = ROWS - 1;

      for (int r = ROWS - 1; r >= 0; r--) {
        if (!grid[r][c].isMatched) {
          if (r != writeRow) {
            grid[writeRow][c] = grid[r][c].copyWith(
              row: writeRow,
              col: c,
            );
          }
          writeRow--;
        }
      }

      // Fill empty spaces with new gems
      for (int r = writeRow; r >= 0; r--) {
        grid[r][c] = Gem(
          id: '${r}_$c',
          type: _randomGemType(),
          row: r,
          col: c,
        );
      }
    }
  }
}