import 'package:equatable/equatable.dart';
import '../entities/gem.dart';

class GameStateModel extends Equatable {
  final List<List<Gem>> grid;
  final int score;
  final int moves;
  final int targetScore;
  final int level;
  final bool isProcessing;

  const GameStateModel({
    required this.grid,
    required this.score,
    required this.moves,
    required this.targetScore,
    required this.level,
    this.isProcessing = false,
  });

  GameStateModel copyWith({
    List<List<Gem>>? grid,
    int? score,
    int? moves,
    int? targetScore,
    int? level,
    bool? isProcessing,
  }) {
    return GameStateModel(
      grid: grid ?? this.grid,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      targetScore: targetScore ?? this.targetScore,
      level: level ?? this.level,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  double get progress => (score / targetScore).clamp(0.0, 1.0);

  bool get isWon => score >= targetScore;
  bool get isLost => moves <= 0 && score < targetScore;

  @override
  List<Object?> get props =>
      [grid, score, moves, targetScore, level, isProcessing];
}