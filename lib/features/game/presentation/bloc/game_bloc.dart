import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/game_utils.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../core/utils/storage_manager.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/gem.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/level.dart';
import 'game_event.dart';
import 'game_state.dart' as bloc_state;

/// Game BLoC - o'yin logikasini boshqaradi
class GameBloc extends Bloc<GameEvent, bloc_state.GameBlocState> {
  final AudioManager _audioManager = AudioManager();
  final StorageManager _storageManager = StorageManager();

  GameBloc() : super(const bloc_state.GameInitial()) {
    on<InitializeGameEvent>(_onInitializeGame);
    on<SwapGemsEvent>(_onSwapGems);
    on<UseZeusPowerEvent>(_onUseZeusPower);
    on<ProcessMatchesEvent>(_onProcessMatches);
    on<FillEmptySpacesEvent>(_onFillEmptySpaces);
    on<ResetComboEvent>(_onResetCombo);
    on<PauseGameEvent>(_onPauseGame);
    on<ResumeGameEvent>(_onResumeGame);
    on<RestartGameEvent>(_onRestartGame);
    on<GameOverEvent>(_onGameOver);
  }

  /// Initialize game with level
  Future<void> _onInitializeGame(
      InitializeGameEvent event,
      Emitter<bloc_state.GameBlocState> emit,
      ) async {
    emit(const bloc_state.GameLoading());

    try {
      final level = LevelData.getLevelById(event.level);
      if (level == null) {
        emit(const bloc_state.GameError('Daraja topilmadi'));
        return;
      }

      // Generate initial grid
      final grid = _generateInitialGrid();

      // Create game state
      final gameState = GameState(
        grid: grid,
        score: 0,
        moves: level.moves,
        targetScore: level.targetScore,
        level: level.id,
        difficulty: level.difficulty,
      );

      emit(bloc_state.GamePlaying(gameState: gameState, level: level));

      // NOTE: Background music disabled - add audio files first
      // await _audioManager.playMusic('sounds/music/game.mp3');
    } catch (e) {
      emit(bloc_state.GameError(e.toString()));
    }
  }

  /// Swap two gems
  Future<void> _onSwapGems(
      SwapGemsEvent event,
      Emitter<bloc_state.GameBlocState> emit,
      ) async {
    if (state is! bloc_state.GamePlaying) return;

    final currentState = state as bloc_state.GamePlaying;
    final gameState = currentState.gameState;

    // Check if move is valid
    if (!GameUtils.areAdjacent(event.fromRow, event.fromCol, event.toRow, event.toCol)) {
      await _audioManager.playSfx(GameSound.buttonClick.assetPath);
      return;
    }

    // Swap gems
    final newGrid = _swapGemsInGrid(
      gameState.grid,
      event.fromRow,
      event.fromCol,
      event.toRow,
      event.toCol,
    );

    // Check for matches
    final matches = _findMatches(newGrid);

    if (matches.isEmpty) {
      // No matches, swap back
      await _audioManager.playSfx(GameSound.buttonClick.assetPath);
      return;
    }

    // Valid move
    await _audioManager.playSfx(GameSound.gemSwap.assetPath);

    final updatedGameState = gameState.copyWith(
      grid: newGrid,
      moves: gameState.moves - 1,
    );

    emit(bloc_state.GamePlaying(
      gameState: updatedGameState,
      level: currentState.level,
    ));

    // Process matches
    add(const ProcessMatchesEvent());
  }

  /// Use Zeus power
  Future<void> _onUseZeusPower(
      UseZeusPowerEvent event,
      Emitter<bloc_state.GameBlocState> emit,
      ) async {
    if (state is! bloc_state.GamePlaying) return;

    final currentState = state as bloc_state.GamePlaying;
    final gameState = currentState.gameState;

    // Check energy
    final cost = GameUtils.getPowerCost(event.power, gameState.difficulty);
    if (gameState.energy < cost) {
      throw InsufficientEnergyException();
    }

    List<List<Gem>> newGrid = List<List<Gem>>.generate(
      gameState.grid.length,
          (i) => List<Gem>.from(gameState.grid[i]),
    );

    switch (event.power) {
      case ZeusPower.thunderStrike:
        newGrid = _applyThunderStrike(newGrid, event.targetCol!);
        await _audioManager.playSfx(GameSound.lightning.assetPath);
        break;
      case ZeusPower.chainLightning:
        newGrid = _applyChainLightning(newGrid);
        await _audioManager.playSfx(GameSound.lightning.assetPath);
        break;
      case ZeusPower.skyWingsDash:
        newGrid = _applySkyWingsDash(newGrid, event.targetRow!, event.targetCol!);
        await _audioManager.playSfx(GameSound.explosion.assetPath);
        break;
      case ZeusPower.wrathOfOlympus:
        newGrid = _applyWrathOfOlympus(newGrid);
        await _audioManager.playSfx(GameSound.explosion.assetPath);
        break;
    }

    final updatedGameState = gameState.copyWith(
      grid: newGrid,
      energy: gameState.energy - cost,
    );

    emit(bloc_state.GamePlaying(
      gameState: updatedGameState,
      level: currentState.level,
    ));

    // Process matches
    add(const ProcessMatchesEvent());
  }

  /// Process matches and update score
  Future<void> _onProcessMatches(
      ProcessMatchesEvent event,
      Emitter<bloc_state.GameBlocState> emit,
      ) async {
    if (state is! bloc_state.GamePlaying) return;

    final currentState = state as bloc_state.GamePlaying;
    var gameState = currentState.gameState;

    emit(bloc_state.GameProcessing(
      gameState: gameState,
      level: currentState.level,
      message: 'Mosliklarni tekshirilmoqda...',
    ));

    await Future.delayed(AppConstants.matchDuration);

    bool foundMatches = true;
    int combo = gameState.comboMultiplier;

    while (foundMatches) {
      final matches = _findMatches(gameState.grid);

      if (matches.isEmpty) {
        foundMatches = false;
        break;
      }

      // Calculate score
      final score = GameUtils.calculateScore(matches.length, combo);
      final newScore = gameState.score + score;

      // Add energy
      final newEnergy = (gameState.energy + matches.length).clamp(0, gameState.maxEnergy);

      // Mark matches
      final newGrid = _markMatches(gameState.grid, matches);

      gameState = gameState.copyWith(
        grid: newGrid,
        score: newScore,
        comboMultiplier: combo + 1,
        energy: newEnergy,
      );

      await _audioManager.playSfx(GameSound.gemMatch.assetPath);

      // Remove matched gems and fill
      add(const FillEmptySpacesEvent());
      await Future.delayed(AppConstants.fallDuration);

      combo++;
    }

    // Check win/lose conditions
    if (gameState.score >= gameState.targetScore) {
      add(const GameOverEvent(true));
    } else if (gameState.moves <= 0) {
      add(const GameOverEvent(false));
    } else {
      emit(bloc_state.GamePlaying(
        gameState: gameState,
        level: currentState.level,
      ));
    }
  }

  /// Fill empty spaces after matches
  Future<void> _onFillEmptySpaces(
      FillEmptySpacesEvent event,
      Emitter<bloc_state.GameBlocState> emit,
      ) async {
    if (state is! bloc_state.GamePlaying && state is! bloc_state.GameProcessing) return;

    // Explicit typing to avoid type errors
    late GameState gameState;
    late Level level;

    if (state is bloc_state.GamePlaying) {
      final playingState = state as bloc_state.GamePlaying;
      gameState = playingState.gameState;
      level = playingState.level;
    } else {
      final processingState = state as bloc_state.GameProcessing;
      gameState = processingState.gameState;
      level = processingState.level;
    }

    final newGrid = _fillEmptyGems(gameState.grid);
    final updatedGameState = gameState.copyWith(grid: newGrid);

    if (state is bloc_state.GamePlaying) {
      emit(bloc_state.GamePlaying(
        gameState: updatedGameState,
        level: level,
      ));
    }
  }

  /// Reset combo multiplier
  void _onResetCombo(
      ResetComboEvent event,
      Emitter<bloc_state.GameBlocState> emit,
      ) {
    if (state is! bloc_state.GamePlaying) return;

    final currentState = state as bloc_state.GamePlaying;
    final updatedGameState = currentState.gameState.copyWith(comboMultiplier: 1);

    emit(bloc_state.GamePlaying(
      gameState: updatedGameState,
      level: currentState.level,
    ));
  }

  /// Pause game
  void _onPauseGame(
      PauseGameEvent event,
      Emitter<bloc_state.GameBlocState> emit,
      ) {
    if (state is! bloc_state.GamePlaying) return;

    final currentState = state as bloc_state.GamePlaying;
    emit(bloc_state.GamePaused(
      gameState: currentState.gameState,
      level: currentState.level,
    ));

    _audioManager.stopMusic();
  }

  /// Resume game
  void _onResumeGame(
      ResumeGameEvent event,
      Emitter<bloc_state.GameBlocState> emit,
      ) {
    if (state is! bloc_state.GamePaused) return;

    final currentState = state as bloc_state.GamePaused;
    emit(bloc_state.GamePlaying(
      gameState: currentState.gameState,
      level: currentState.level,
    ));

    // NOTE: Background music disabled - add audio files first
    // await _audioManager.playMusic('sounds/music/game.mp3');
  }

  /// Restart game
  void _onRestartGame(
      RestartGameEvent event,
      Emitter<bloc_state.GameBlocState> emit,
      ) {
    if (state is bloc_state.GamePlaying || state is bloc_state.GamePaused || state is bloc_state.GameOver) {
      final level = state is bloc_state.GamePlaying
          ? (state as bloc_state.GamePlaying).level
          : state is bloc_state.GamePaused
          ? (state as bloc_state.GamePaused).level
          : (state as bloc_state.GameOver).level;

      add(InitializeGameEvent(level.id));
    }
  }

  /// Game over
  Future<void> _onGameOver(
      GameOverEvent event,
      Emitter<bloc_state.GameBlocState> emit,
      ) async {
    if (state is! bloc_state.GamePlaying && state is! bloc_state.GameProcessing) return;

    // Explicit typing to avoid type errors
    late GameState gameState;
    late Level level;

    if (state is bloc_state.GamePlaying) {
      final playingState = state as bloc_state.GamePlaying;
      gameState = playingState.gameState;
      level = playingState.level;
    } else {
      final processingState = state as bloc_state.GameProcessing;
      gameState = processingState.gameState;
      level = processingState.level;
    }

    final stars = gameState.stars;

    // Save high score
    final currentHighScore = _storageManager.getHighScore();
    if (gameState.score > currentHighScore) {
      await _storageManager.saveHighScore(gameState.score);
    }

    // Play victory/defeat sound
    if (event.isVictory) {
      await _audioManager.playSfx(GameSound.victory.assetPath);
    } else {
      await _audioManager.playSfx(GameSound.defeat.assetPath);
    }

    emit(bloc_state.GameOver(
      gameState: gameState,
      level: level,
      isVictory: event.isVictory,
      stars: stars,
      finalScore: gameState.score,
    ));
  }

  // Helper methods

  /// Generate initial grid
  List<List<Gem>> _generateInitialGrid() {
    final grid = <List<Gem>>[];

    for (int row = 0; row < AppConstants.gridRows; row++) {
      final rowList = <Gem>[];
      for (int col = 0; col < AppConstants.gridColumns; col++) {
        rowList.add(Gem(
          id: '${row}_$col',
          type: GameUtils.randomGemWithSpecial(),
          row: row,
          column: col,
        ));
      }
      grid.add(rowList);
    }

    // Remove initial matches
    return _removeInitialMatches(grid);
  }

  /// Remove initial matches
  List<List<Gem>> _removeInitialMatches(List<List<Gem>> grid) {
    bool hasMatches = true;
    var newGrid = grid;

    while (hasMatches) {
      final matches = _findMatches(newGrid);
      if (matches.isEmpty) {
        hasMatches = false;
      } else {
        // Replace matched gems
        for (final gem in matches) {
          newGrid[gem.row][gem.column] = gem.copyWith(
            type: GameUtils.randomGemType(),
          );
        }
      }
    }

    return newGrid;
  }

  /// Swap gems in grid
  List<List<Gem>> _swapGemsInGrid(
      List<List<Gem>> grid,
      int fromRow,
      int fromCol,
      int toRow,
      int toCol,
      ) {
    final newGrid = List<List<Gem>>.generate(
      grid.length,
          (i) => List<Gem>.from(grid[i]),
    );

    final gem1 = newGrid[fromRow][fromCol];
    final gem2 = newGrid[toRow][toCol];

    newGrid[fromRow][fromCol] = gem2.copyWith(row: fromRow, column: fromCol);
    newGrid[toRow][toCol] = gem1.copyWith(row: toRow, column: toCol);

    return newGrid;
  }

  /// Find all matches in grid
  List<Gem> _findMatches(List<List<Gem>> grid) {
    final Set<Gem> matches = {};

    // Check horizontal matches
    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length - 2; col++) {
        final gem1 = grid[row][col];
        final gem2 = grid[row][col + 1];
        final gem3 = grid[row][col + 2];

        if (gem1.type == gem2.type && gem2.type == gem3.type && !gem1.isSpecialGem) {
          matches.addAll([gem1, gem2, gem3]);
        }
      }
    }

    // Check vertical matches
    for (int col = 0; col < grid[0].length; col++) {
      for (int row = 0; row < grid.length - 2; row++) {
        final gem1 = grid[row][col];
        final gem2 = grid[row + 1][col];
        final gem3 = grid[row + 2][col];

        if (gem1.type == gem2.type && gem2.type == gem3.type && !gem1.isSpecialGem) {
          matches.addAll([gem1, gem2, gem3]);
        }
      }
    }

    return matches.toList();
  }

  /// Mark matches for removal
  List<List<Gem>> _markMatches(List<List<Gem>> grid, List<Gem> matches) {
    final newGrid = List<List<Gem>>.generate(
      grid.length,
          (i) => List<Gem>.from(grid[i]),
    );

    for (final gem in matches) {
      newGrid[gem.row][gem.column] = gem.copyWith(isMatched: true);
    }

    return newGrid;
  }

  /// Fill empty gems (remove matched and drop)
  List<List<Gem>> _fillEmptyGems(List<List<Gem>> grid) {
    final newGrid = List<List<Gem>>.generate(
      grid.length,
          (i) => List<Gem>.from(grid[i]),
    );

    // Remove matched gems and drop
    for (int col = 0; col < newGrid[0].length; col++) {
      int emptyRow = newGrid.length - 1;

      for (int row = newGrid.length - 1; row >= 0; row--) {
        if (!newGrid[row][col].isMatched) {
          if (row != emptyRow) {
            newGrid[emptyRow][col] = newGrid[row][col].copyWith(row: emptyRow);
          }
          emptyRow--;
        }
      }

      // Fill top with new gems
      for (int row = emptyRow; row >= 0; row--) {
        newGrid[row][col] = Gem(
          id: '${row}_$col',
          type: GameUtils.randomGemWithSpecial(),
          row: row,
          column: col,
          isFalling: true,
        );
      }
    }

    return newGrid;
  }

  // Zeus powers

  List<List<Gem>> _applyThunderStrike(List<List<Gem>> grid, int column) {
    final newGrid = List<List<Gem>>.generate(
      grid.length,
          (i) => List<Gem>.from(grid[i]),
    );

    for (int row = 0; row < newGrid.length; row++) {
      newGrid[row][column] = newGrid[row][column].copyWith(isMatched: true);
    }

    return newGrid;
  }

  List<List<Gem>> _applyChainLightning(List<List<Gem>> grid) {
    final newGrid = List<List<Gem>>.generate(
      grid.length,
          (i) => List<Gem>.from(grid[i]),
    );

    // Randomly remove 5-8 gems
    final random = Random();
    final count = 5 + random.nextInt(4);

    for (int i = 0; i < count; i++) {
      final row = random.nextInt(newGrid.length);
      final col = random.nextInt(newGrid[0].length);
      newGrid[row][col] = newGrid[row][col].copyWith(isMatched: true);
    }

    return newGrid;
  }

  List<List<Gem>> _applySkyWingsDash(List<List<Gem>> grid, int row, int col) {
    final newGrid = List<List<Gem>>.generate(
      grid.length,
          (i) => List<Gem>.from(grid[i]),
    );

    // 3x3 explosion
    for (int r = row - 1; r <= row + 1; r++) {
      for (int c = col - 1; c <= col + 1; c++) {
        if (r >= 0 && r < newGrid.length && c >= 0 && c < newGrid[0].length) {
          newGrid[r][c] = newGrid[r][c].copyWith(isMatched: true);
        }
      }
    }

    return newGrid;
  }

  List<List<Gem>> _applyWrathOfOlympus(List<List<Gem>> grid) {
    final newGrid = List<List<Gem>>.generate(
      grid.length,
          (i) => List<Gem>.from(grid[i]),
    );

    // Clear half the board
    for (int row = 0; row < newGrid.length ~/ 2; row++) {
      for (int col = 0; col < newGrid[row].length; col++) {
        newGrid[row][col] = newGrid[row][col].copyWith(isMatched: true);
      }
    }

    return newGrid;
  }
}