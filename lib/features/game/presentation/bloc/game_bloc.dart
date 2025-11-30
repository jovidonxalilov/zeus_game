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

  // ----------------- INIT -----------------
  Future<void> _onInit(InitGameEvent event, Emitter<GameState> emit) async {
    emit(const GameLoading());
    await Future.delayed(const Duration(milliseconds: 300));

    // Generate until we have a valid grid (no immediate matches and at least one possible move)
    List<List<Gem>> grid;
    int attempts = 0;
    do {
      grid = _generateGrid();
      attempts++;
      if (attempts > 10) break; // safety
    } while (_findMatches(grid).isNotEmpty || !_hasPossibleMoves(grid));

    final gameState = GameStateModel(
      grid: grid,
      score: 0,
      moves: 30,
      targetScore: 1000 + (event.level - 1) * 500,
      level: event.level,
      isProcessing: false,
    );

    print('✅ Game initialized with possible moves');
    emit(GameReady(gameState));
  }

  // ----------------- SWAP -----------------
  Future<void> _onSwap(SwapGemsEvent event, Emitter<GameState> emit) async {
    if (state is! GameReady) return;
    final current = (state as GameReady).gameState;
    if (current.isProcessing) return;

    final row1 = event.row1;
    final col1 = event.col1;
    final row2 = event.row2;
    final col2 = event.col2;

    // adjacency check
    final rowDiff = (row1 - row2).abs();
    final colDiff = (col1 - col2).abs();
    final isAdjacent = (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
    if (!isAdjacent) return;

    // deep copy grid
    final grid = _copyGrid(current.grid);

    // perform swap (mark animating)
    final a = grid[row1][col1];
    final b = grid[row2][col2];

    grid[row1][col1] = b.copyWith(row: row1, col: col1, isAnimating: true);
    grid[row2][col2] = a.copyWith(row: row2, col: col2, isAnimating: true);

    // emit animating
    emit(GameReady(current.copyWith(grid: grid, isProcessing: true)));

    // small animation delay
    await Future.delayed(const Duration(milliseconds: 250));

    // check if swap creates matches (including special interactions)
    final matches = _findMatches(grid);

    if (matches.isEmpty) {
      // swap back and stop processing
      final temp = grid[row1][col1];
      grid[row1][col1] = grid[row2][col2].copyWith(row: row1, col: col1, isAnimating: false);
      grid[row2][col2] = temp.copyWith(row: row2, col: col2, isAnimating: false);

      emit(GameReady(current.copyWith(grid: grid, isProcessing: false)));
      return;
    }

    // Valid move: decrement moves, clear anim flags
    final newMoves = current.moves - 1;
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS; c++) {
        if (grid[r][c].isAnimating) {
          grid[r][c] = grid[r][c].copyWith(isAnimating: false);
        }
      }
    }

    emit(GameReady(current.copyWith(grid: grid, moves: newMoves, isProcessing: true)));

    // start processing matches
    add(const ProcessMatchesEvent());
  }

  // ----------------- PROCESS MATCHES -----------------
  Future<void> _onProcessMatches(ProcessMatchesEvent event, Emitter<GameState> emit) async {
    if (state is! GameReady && state is! GameProcessing) return;

    var current = (state as GameReady).gameState;
    var grid = _copyGrid(current.grid);
    var totalScore = current.score;
    int combo = 1;
    bool foundMatches = true;

    while (foundMatches) {
      // find matches and special creation hints
      final DetectionResult detection = _findMatchesWithSpecials(grid);

      if (detection.matchedGems.isEmpty) {
        foundMatches = false;
        break;
      }

      // mark matched
      for (final g in detection.matchedGems) {
        grid[g.row][g.col] = g.copyWith(isMatched: true);
      }

      // Play sound
      SoundService().playMatch();

      // scoring
      final points = detection.matchedGems.length * 100 * combo;
      totalScore += points;

      // emit processing state to animate destruction
      emit(GameProcessing(current.copyWith(grid: grid, score: totalScore)));
      await Future.delayed(const Duration(milliseconds: 350));

      // create special gems BEFORE removing matches:
      // For each special creation instruction, set specialType on that gem and ensure it's not removed.
      for (final entry in detection.specialCreations.entries) {
        final pos = entry.key.split('_');
        final r = int.parse(pos[0]);
        final c = int.parse(pos[1]);
        final sType = entry.value;

        // place special gem at r,c (keep its base type but assign specialType)
        final base = grid[r][c];
        // If the base is currently matched (part of removal), unmark it and assign special
        grid[r][c] = base.copyWith(isMatched: false, specialType: sType);
      }

      // remove matched gems and apply gravity
      _processGravity(grid);

      // play fall sound
      SoundService().playFall();

      // show falling animation
      emit(GameProcessing(current.copyWith(grid: grid, score: totalScore)));
      await Future.delayed(const Duration(milliseconds: 350));

      combo++;
    }

    // ✅ CRITICAL FIX: Check for possible moves after refill
    int reshuffleAttempts = 0;
    while (!_hasPossibleMoves(grid) && reshuffleAttempts < 5) {
      print('⚠️ No possible moves after refill! Reshuffling... (attempt ${reshuffleAttempts + 1})');
      _shuffleGrid(grid);
      reshuffleAttempts++;
    }
    
    if (!_hasPossibleMoves(grid)) {
      print('❌ Still no moves after reshuffling - regenerating entire grid');
      // Last resort: regenerate grid
      grid = _generateValidGrid();
    } else {
      print('✅ Grid has possible moves');
    }

    // finalize
    final finalState = current.copyWith(grid: grid, score: totalScore, isProcessing: false);

    if (finalState.isWon) {
      SoundService().playVictory();
      emit(GameWon(finalState));
    } else if (finalState.isLost) {
      SoundService().playFailure();
      emit(GameLost(finalState));
    } else {
      emit(GameReady(finalState));
    }
  }

  // ----------------- RESTART -----------------
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

  // ----------------- GRID GENERATION -----------------
  List<List<Gem>> _generateGrid() {
    final grid = List.generate(
      ROWS,
      (r) => List.generate(
        COLS,
        (c) => Gem(
          id: '${r}_$c',
          type: _randomBasicGemType(),
          row: r,
          col: c,
        ),
      ),
    );

    // Fill sequentially ensuring no immediate 3-in-row while taking into account neighbors
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS; c++) {
        grid[r][c] = Gem(
          id: '${r}_$c',
          type: _getSafeRandomType(grid, r, c),
          row: r,
          col: c,
        );
      }
    }

    return grid;
  }

  // Generate grid that is guaranteed valid (no matches, has possible moves)
  List<List<Gem>> _generateValidGrid() {
    List<List<Gem>> grid;
    int attempts = 0;
    do {
      grid = _generateGrid();
      attempts++;
      if (attempts > 20) {
        print('⚠️ Couldn\'t generate valid grid after 20 attempts, using best effort');
        break;
      }
    } while (_findMatches(grid).isNotEmpty || !_hasPossibleMoves(grid));
    
    return grid;
  }

  // ✅ NEW: Shuffle grid to create new possible moves
  void _shuffleGrid(List<List<Gem>> grid) {
    final random = Random();
    final allGems = <Gem>[];
    
    // Collect all gems
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS; c++) {
        allGems.add(grid[r][c]);
      }
    }
    
    // Shuffle
    allGems.shuffle(random);
    
    // Place back with safe types to avoid immediate matches
    int index = 0;
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS; c++) {
        final gem = allGems[index++];
        grid[r][c] = Gem(
          id: '${r}_$c',
          type: _getSafeRandomType(grid, r, c),
          row: r,
          col: c,
          specialType: gem.specialType, // Preserve special types
        );
      }
    }
  }

  // ----------------- UTILS -----------------
  List<List<Gem>> _copyGrid(List<List<Gem>> grid) {
    return List.generate(
      ROWS,
      (r) => List.generate(
        COLS,
        (c) => grid[r][c].copyWith(),
      ),
    );
  }

  GemType _randomBasicGemType() {
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

  // choose a gem type that won't immediately make a 3-in-row considering all neighbors
  GemType _getSafeRandomType(List<List<Gem>> grid, int row, int col) {
    const basicGems = [
      GemType.red,
      GemType.blue,
      GemType.green,
      GemType.yellow,
      GemType.purple,
      GemType.cyan,
    ];

    List<GemType> possible = List.from(basicGems);

    bool createsMatch(GemType t) {
      // Temporarily set this type to test neighbors existence (checking gorizontal & vertical patterns)
      // HORIZONTAL checks
      // left-left + left
      if (col >= 2 &&
          grid[row][col - 1].type == t &&
          grid[row][col - 2].type == t) return true;
      // left + right (only if right exists)
      if (col >= 1 && col < COLS - 1 &&
          grid[row][col - 1].type == t &&
          grid[row][col + 1].type == t) return true;
      // right + right-right (only if they exist)
      if (col < COLS - 2 &&
          grid[row][col + 1].type == t &&
          grid[row][col + 2].type == t) return true;

      // VERTICAL checks
      // up-up + up
      if (row >= 2 &&
          grid[row - 1][col].type == t &&
          grid[row - 2][col].type == t) return true;
      // up + down (only if down exists)
      if (row >= 1 && row < ROWS - 1 &&
          grid[row - 1][col].type == t &&
          grid[row + 1][col].type == t) return true;
      // down + down-down (only if they exist)
      if (row < ROWS - 2 &&
          grid[row + 1][col].type == t &&
          grid[row + 2][col].type == t) return true;

      return false;
    }

    possible.removeWhere((t) => createsMatch(t));

    if (possible.isEmpty) {
      // fallback (very rare)
      return basicGems[Random().nextInt(basicGems.length)];
    }

    return possible[Random().nextInt(possible.length)];
  }

  // ----------------- POSSIBLE MOVES CHECK -----------------
  bool _hasPossibleMoves(List<List<Gem>> grid) {
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS; c++) {
        // swap right
        if (c < COLS - 1) {
          final test = _copyGrid(grid);
          final t = test[r][c];
          test[r][c] = test[r][c + 1].copyWith(row: r, col: c);
          test[r][c + 1] = t.copyWith(row: r, col: c + 1);
          if (_findMatches(test).isNotEmpty) return true;
        }
        // swap down
        if (r < ROWS - 1) {
          final test = _copyGrid(grid);
          final t = test[r][c];
          test[r][c] = test[r + 1][c].copyWith(row: r, col: c);
          test[r + 1][c] = t.copyWith(row: r + 1, col: c);
          if (_findMatches(test).isNotEmpty) return true;
        }
      }
    }
    return false;
  }

  // ----------------- MATCH DETECTION -----------------
  // Return only matched gems (no order guarantee)
  List<Gem> _findMatches(List<List<Gem>> grid) {
    final Set<String> matchedIds = {};

    // horizontal
    for (int r = 0; r < ROWS; r++) {
      int runStart = 0;
      for (int c = 1; c <= COLS; c++) {
        if (c < COLS && grid[r][c].type == grid[r][runStart].type && !grid[r][c].isMatched && !grid[r][runStart].isMatched) {
          // continue run
        } else {
          final runLen = c - runStart;
          if (runLen >= 3) {
            for (int k = runStart; k < c; k++) {
              matchedIds.add(grid[r][k].id);
            }
          }
          runStart = c;
        }
      }
    }

    // vertical
    for (int c = 0; c < COLS; c++) {
      int runStart = 0;
      for (int r = 1; r <= ROWS; r++) {
        if (r < ROWS && grid[r][c].type == grid[runStart][c].type && !grid[r][c].isMatched && !grid[runStart][c].isMatched) {
          // continue run
        } else {
          final runLen = r - runStart;
          if (runLen >= 3) {
            for (int k = runStart; k < r; k++) {
              matchedIds.add(grid[k][c].id);
            }
          }
          runStart = r;
        }
      }
    }

    // convert ids to Gem list
    final List<Gem> result = [];
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS; c++) {
        if (matchedIds.contains(grid[r][c].id)) result.add(grid[r][c]);
      }
    }
    return result;
  }

  // Extended detection that also returns special gem creation instructions
  DetectionResult _findMatchesWithSpecials(List<List<Gem>> grid) {
    final Set<String> matchedIds = {};
    final List<Run> horizontalRuns = [];
    final List<Run> verticalRuns = [];

    // find horizontal runs
    for (int r = 0; r < ROWS; r++) {
      int start = 0;
      for (int c = 1; c <= COLS; c++) {
        if (c < COLS && grid[r][c].type == grid[r][start].type && !grid[r][c].isMatched && !grid[r][start].isMatched) {
          // extend
        } else {
          final len = c - start;
          if (len >= 3) {
            horizontalRuns.add(Run(r: r, cStart: start, cEnd: c - 1, length: len, isHorizontal: true));
            for (int k = start; k < c; k++) matchedIds.add(grid[r][k].id);
          }
          start = c;
        }
      }
    }

    // find vertical runs
    for (int c = 0; c < COLS; c++) {
      int start = 0;
      for (int r = 1; r <= ROWS; r++) {
        if (r < ROWS && grid[r][c].type == grid[start][c].type && !grid[r][c].isMatched && !grid[start][c].isMatched) {
          // extend
        } else {
          final len = r - start;
          if (len >= 3) {
            verticalRuns.add(Run(rStart: start, c: c, rEnd: r - 1, length: len, isHorizontal: false));
            for (int k = start; k < r; k++) matchedIds.add(grid[k][c].id);
          }
          start = r;
        }
      }
    }

    // Decide special creations:
    // - any run length == 4 -> lightning at a logical pivot (prefer the moved gem position if known; here choose middle)
    // - run length >=5 -> storm
    // - intersection of horizontal & vertical runs -> temple (T/Cross)
    // - L-shape (one run intersects another but not symmetrical?) -> wings (we'll treat any intersection as temple if both >=3)
    final Map<String, SpecialGemType> specialCreations = {};

    // intersections: check cells that are in both horizontal and vertical runs
    for (final h in horizontalRuns) {
      for (final v in verticalRuns) {
        final hr = h.r;
        final hcStart = h.cStart;
        final hcEnd = h.cEnd;
        final vrStart = v.rStart;
        final vrEnd = v.rEnd;
        final vc = v.c;
        // intersection cell is (hr, vc)
        if (vc >= hcStart && vc <= hcEnd && hr >= vrStart && hr <= vrEnd) {
          // create temple at intersection
          specialCreations['${hr}_$vc'] = SpecialGemType.temple;
        }
      }
    }

    // runs for length-based specials (horizontal)
    for (final h in horizontalRuns) {
      if (h.length >= 5) {
        // put storm near middle
        final mid = (h.cStart + h.cEnd) ~/ 2;
        specialCreations['${h.r}_$mid'] = SpecialGemType.storm;
      } else if (h.length == 4) {
        final mid = (h.cStart + h.cEnd) ~/ 2;
        // if already has temple/storm don't override
        specialCreations.putIfAbsent('${h.r}_$mid', () => SpecialGemType.lightning);
      } else if (h.length == 3) {
        // no special for pure 3 unless intersection handled above
      }
    }

    // runs for length-based specials (vertical)
    for (final v in verticalRuns) {
      if (v.length >= 5) {
        final mid = (v.rStart + v.rEnd) ~/ 2;
        specialCreations.putIfAbsent('${mid}_${v.c}', () => SpecialGemType.storm);
      } else if (v.length == 4) {
        final mid = (v.rStart + v.rEnd) ~/ 2;
        specialCreations.putIfAbsent('${mid}_${v.c}', () => SpecialGemType.lightning);
      }
    }

    // Convert matchedIds to Gem list
    final matchedList = <Gem>[];
    for (int r = 0; r < ROWS; r++) {
      for (int c = 0; c < COLS; c++) {
        if (matchedIds.contains(grid[r][c].id)) matchedList.add(grid[r][c]);
      }
    }

    return DetectionResult(matchedGems: matchedList, specialCreations: specialCreations);
  }

  // ----------------- GRAVITY & REFILL -----------------
  void _processGravity(List<List<Gem>> grid) {
    for (int c = 0; c < COLS; c++) {
      int write = ROWS - 1;
      for (int r = ROWS - 1; r >= 0; r--) {
        if (!grid[r][c].isMatched) {
          if (r != write) {
            grid[write][c] = grid[r][c].copyWith(row: write, col: c);
          }
          write--;
        }
      }

      // fill remaining with new gems (safe types)
      for (int r = write; r >= 0; r--) {
        grid[r][c] = Gem(
          id: '${r}_$c',
          type: _getSafeRandomType(grid, r, c),
          row: r,
          col: c,
          isMatched: false,
          isAnimating: false,
          specialType: SpecialGemType.none,
        );
      }
    }
  }
}

// ----------------- Helper classes -----------------
class Run {
  // horizontal: r, cStart, cEnd
  // vertical: rStart, rEnd, c
  final int r;
  final int cStart;
  final int cEnd;
  final int rStart;
  final int rEnd;
  final int c;
  final int length;
  final bool isHorizontal;

  Run({
    this.r = -1,
    this.cStart = -1,
    this.cEnd = -1,
    this.rStart = -1,
    this.rEnd = -1,
    this.c = -1,
    required this.length,
    required this.isHorizontal,
  });
}

class DetectionResult {
  final List<Gem> matchedGems;
  final Map<String, SpecialGemType> specialCreations;
  DetectionResult({
    required this.matchedGems,
    required this.specialCreations,
  });
}