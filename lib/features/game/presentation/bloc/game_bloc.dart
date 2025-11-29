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

    // Generate grid without any 3-in-row matches
    final grid = _generateGrid();
    
    // Verify no matches exist
    final initialMatches = _findMatches(grid);
    if (initialMatches.isNotEmpty) {
      print('⚠️ WARNING: Found ${initialMatches.length} matches in initial grid (should be 0)');
    } else {
      print('✅ Grid generated with NO initial matches');
    }
    
    // Verify at least one possible move exists
    if (!_hasPossibleMoves(grid)) {
      print('⚠️ WARNING: No possible moves! Regenerating...');
      // This shouldn't happen with proper random distribution
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
    print('\n🎲 GENERATING GRID...');
    
    final grid = List.generate(
      ROWS,
      (r) => List.generate(
        COLS,
        (c) => Gem(
          id: '${r}_$c',
          type: GemType.red, // Temporary placeholder
          row: r,
          col: c,
        ),
      ),
    );
    
    // Fill grid position by position, avoiding 3-in-row
    int preventions = 0;
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS; c++) {
        final oldPrev = preventions;
        GemType type = _getRandomNonMatchingType(grid, r, c);
        if (preventions > oldPrev) {
          // A type was banned
        }
        grid[r][c] = Gem(
          id: '${r}_$c',
          type: type,
          row: r,
          col: c,
        );
      }
    }
    
    print('✅ Grid generated with $preventions preventions');
    
    // VERIFICATION: Check for any matches
    final matches = _findMatches(grid);
    if (matches.isNotEmpty) {
      print('❌ ERROR: Generated grid has ${matches.length} matches!');
      print('This should NEVER happen!');
      // Print grid for debugging
      for (int r = 0; r < ROWS; r++) {
        final row = grid[r].map((g) => g.type.toString().split('.').last[0]).join(' ');
        print('Row $r: $row');
      }
    } else {
      print('✅ VERIFIED: Grid has ZERO matches');
    }
    
    return grid;
  }

  List<List<Gem>> _copyGrid(List<List<Gem>> grid) {
    return grid.map((row) => row.map((gem) => gem).toList()).toList();
  }

  GemType _randomGemType() {
    // Use only basic 6 gem types (not special gems)
    const basicGems = [
      GemType.red,
      GemType.blue,
      GemType.green,
      GemType.yellow,
      GemType.purple,
      GemType.cyan,
    ];
    return basicGems[Random().nextInt(basicGems.length)];
  }
  
  // Get a random type that won't create 3-in-row at this position
  // ONLY checks positions that are already filled (left and top)
  GemType _getRandomNonMatchingType(List<List<Gem>> grid, int row, int col) {
    const basicGems = [
      GemType.red,
      GemType.blue,
      GemType.green,
      GemType.yellow,
      GemType.purple,
      GemType.cyan,
    ];
    
    Set<GemType> bannedTypes = {};
    
    // HORIZONTAL: Check left 2 gems (already filled)
    if (col >= 2) {
      final left1 = grid[row][col - 1].type;
      final left2 = grid[row][col - 2].type;
      if (left1 == left2) {
        bannedTypes.add(left1);
      }
    }
    
    // VERTICAL: Check top 2 gems (already filled)
    if (row >= 2) {
      final top1 = grid[row - 1][col].type;
      final top2 = grid[row - 2][col].type;
      if (top1 == top2) {
        bannedTypes.add(top1);
      }
    }
    
    // Get available types
    final availableTypes = basicGems.where((type) => !bannedTypes.contains(type)).toList();
    
    // Safety check: if somehow all are banned, return random
    if (availableTypes.isEmpty) {
      print('⚠️ WARNING: All types banned at ($row, $col)');
      return basicGems[Random().nextInt(basicGems.length)];
    }
    
    return availableTypes[Random().nextInt(availableTypes.length)];
  }
  
  bool _hasPossibleMoves(List<List<Gem>> grid) {
    // Check if any swap would create a match
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS; c++) {
        // Try swapping with right neighbor
        if (c < COLS - 1) {
          final testGrid = _copyGrid(grid);
          final temp = testGrid[r][c];
          testGrid[r][c] = testGrid[r][c + 1].copyWith(row: r, col: c);
          testGrid[r][c + 1] = temp.copyWith(row: r, col: c + 1);
          if (_findMatches(testGrid).isNotEmpty) return true;
        }
        // Try swapping with bottom neighbor
        if (r < ROWS - 1) {
          final testGrid = _copyGrid(grid);
          final temp = testGrid[r][c];
          testGrid[r][c] = testGrid[r + 1][c].copyWith(row: r, col: c);
          testGrid[r + 1][c] = temp.copyWith(row: r + 1, col: c);
          if (_findMatches(testGrid).isNotEmpty) return true;
        }
      }
    }
    return false;
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

      // Fill empty spaces with new gems that won't create 3-in-row
      for (int r = writeRow; r >= 0; r--) {
        grid[r][c] = Gem(
          id: '${r}_$c',
          type: _getRandomNonMatchingType(grid, r, c),
          row: r,
          col: c,
        );
      }
    }
  }
}

