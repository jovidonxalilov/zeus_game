import 'package:equatable/equatable.dart';
import 'package:zeus_game/core/constants/app_constants.dart';

/// Level entity
class Level extends Equatable {
  final int id;
  final String name;
  final String description;
  final int targetScore;
  final int moves;
  final GameDifficulty difficulty;
  final LevelStatus status;
  final int stars;
  final int highScore;
  final String? bossName;
  final int? bossHealth;

  const Level({
    required this.id,
    required this.name,
    required this.description,
    required this.targetScore,
    required this.moves,
    required this.difficulty,
    this.status = LevelStatus.locked,
    this.stars = 0,
    this.highScore = 0,
    this.bossName,
    this.bossHealth,
  });

  /// Copy with method
  Level copyWith({
    int? id,
    String? name,
    String? description,
    int? targetScore,
    int? moves,
    GameDifficulty? difficulty,
    LevelStatus? status,
    int? stars,
    int? highScore,
    String? bossName,
    int? bossHealth,
  }) {
    return Level(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetScore: targetScore ?? this.targetScore,
      moves: moves ?? this.moves,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      stars: stars ?? this.stars,
      highScore: highScore ?? this.highScore,
      bossName: bossName ?? this.bossName,
      bossHealth: bossHealth ?? this.bossHealth,
    );
  }

  /// Check if level is playable
  bool get isPlayable {
    return status == LevelStatus.unlocked || status == LevelStatus.completed;
  }

  /// Check if level has boss
  bool get hasBoss {
    return bossName != null && bossHealth != null;
  }

  /// Get difficulty color
  int get difficultyColor {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 0xFF00FF00;
      case GameDifficulty.medium:
        return 0xFFFFFF00;
      case GameDifficulty.hard:
        return 0xFFFF8C00;
      case GameDifficulty.olympus:
        return 0xFFFF0000;
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        targetScore,
        moves,
        difficulty,
        status,
        stars,
        highScore,
        bossName,
        bossHealth,
      ];
}

/// Predefined levels
class LevelData {
  static List<Level> get allLevels => [
    // Chapter 1: Gates of Olympus
    const Level(
      id: 1,
      name: 'Beginner Trial',
      description: 'Open the gates of Olympus',
      targetScore: 1000,
      moves: 30,
      difficulty: GameDifficulty.easy,
      status: LevelStatus.unlocked,
    ),
    const Level(
      id: 2,
      name: 'Power of Lightning',
      description: 'Control the lightning',
      targetScore: 1500,
      moves: 28,
      difficulty: GameDifficulty.easy,
    ),
    const Level(
      id: 3,
      name: 'Trial of Wings',
      description: 'Use the power of wings',
      targetScore: 2000,
      moves: 26,
      difficulty: GameDifficulty.easy,
    ),
    const Level(
      id: 4,
      name: 'Temple Defense',
      description: 'Defend the sacred temple',
      targetScore: 2500,
      moves: 25,
      difficulty: GameDifficulty.easy,
    ),
    const Level(
      id: 5,
      name: 'Cyclops Boss',
      description: 'Defeat the first boss',
      targetScore: 3000,
      moves: 24,
      difficulty: GameDifficulty.medium,
      bossName: 'Cyclops',
      bossHealth: 100,
    ),

    // Chapter 2: Eternal Mountain
    const Level(
      id: 6,
      name: 'Mountain Path',
      description: 'Climb the Olympus mountain',
      targetScore: 3500,
      moves: 23,
      difficulty: GameDifficulty.medium,
    ),
    const Level(
      id: 7,
      name: 'Snowstorm',
      description: 'Survive the fierce storm',
      targetScore: 4000,
      moves: 22,
      difficulty: GameDifficulty.medium,
    ),
    const Level(
      id: 8,
      name: 'Stone Golem',
      description: 'Destroy the stone golem',
      targetScore: 4500,
      moves: 21,
      difficulty: GameDifficulty.medium,
      bossName: 'Stone Golem',
      bossHealth: 150,
    ),
    const Level(
      id: 9,
      name: 'Reach the Summit',
      description: 'Make it to the mountain peak',
      targetScore: 5000,
      moves: 20,
      difficulty: GameDifficulty.medium,
    ),
    const Level(
      id: 10,
      name: 'God of the Mountain',
      description: 'Defeat the mountain god',
      targetScore: 6000,
      moves: 20,
      difficulty: GameDifficulty.hard,
      bossName: 'Mountain God',
      bossHealth: 200,
    ),
  ];

  /// Get level by ID
  static Level? getLevelById(int id) {
    try {
      return allLevels.firstWhere((level) => level.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get levels by difficulty
  static List<Level> getLevelsByDifficulty(GameDifficulty difficulty) {
    return allLevels.where((level) => level.difficulty == difficulty).toList();
  }
}
