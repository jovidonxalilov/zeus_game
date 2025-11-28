import 'package:equatable/equatable.dart';
import 'package:zeus_game/core/constants/app_constants.dart';
import 'gem.dart';

/// Game state entity
class GameState extends Equatable {
  final List<List<Gem>> grid;
  final int score;
  final int moves;
  final int targetScore;
  final int level;
  final int comboMultiplier;
  final int energy;
  final int maxEnergy;
  final bool isProcessing;
  final bool isGameOver;
  final bool isVictory;
  final GameDifficulty difficulty;
  
  const GameState({
    required this.grid,
    required this.score,
    required this.moves,
    required this.targetScore,
    required this.level,
    this.comboMultiplier = 1,
    this.energy = 0,
    this.maxEnergy = 100,
    this.isProcessing = false,
    this.isGameOver = false,
    this.isVictory = false,
    this.difficulty = GameDifficulty.easy,
  });
  
  /// Copy with method
  GameState copyWith({
    List<List<Gem>>? grid,
    int? score,
    int? moves,
    int? targetScore,
    int? level,
    int? comboMultiplier,
    int? energy,
    int? maxEnergy,
    bool? isProcessing,
    bool? isGameOver,
    bool? isVictory,
    GameDifficulty? difficulty,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      targetScore: targetScore ?? this.targetScore,
      level: level ?? this.level,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      isProcessing: isProcessing ?? this.isProcessing,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
      difficulty: difficulty ?? this.difficulty,
    );
  }
  
  /// Get gem at position
  Gem? getGemAt(int row, int column) {
    if (row >= 0 && row < grid.length && column >= 0 && column < grid[0].length) {
      return grid[row][column];
    }
    return null;
  }
  
  /// Calculate progress percentage
  double get progressPercentage {
    return (score / targetScore).clamp(0.0, 1.0);
  }
  
  /// Calculate stars
  int get stars {
    if (score >= targetScore * 2) return 3;
    if (score >= targetScore * 1.5) return 2;
    if (score >= targetScore) return 1;
    return 0;
  }
  
  @override
  List<Object?> get props => [
        grid,
        score,
        moves,
        targetScore,
        level,
        comboMultiplier,
        energy,
        maxEnergy,
        isProcessing,
        isGameOver,
        isVictory,
        difficulty,
      ];
}
