import 'dart:math';
import '../constants/app_constants.dart';

/// Game utility functions
class GameUtils {
  /// Generate random gem type
  static GemType randomGemType() {
    final random = Random();
    final types = [
      GemType.red,
      GemType.blue,
      GemType.green,
      GemType.yellow,
      GemType.purple,
      GemType.cyan,
    ];
    return types[random.nextInt(types.length)];
  }
  
  /// Generate special gem with chance
  static GemType randomGemWithSpecial() {
    final random = Random();
    final chance = random.nextDouble();
    
    // 3-5% chance for special gems
    if (chance < 0.03) {
      return GemType.wings;
    } else if (chance < 0.04) {
      return GemType.lyre;
    } else if (chance < 0.05) {
      return GemType.temple;
    }
    
    return randomGemType();
  }
  
  /// Check if two positions are adjacent
  static bool areAdjacent(int row1, int col1, int row2, int col2) {
    final rowDiff = (row1 - row2).abs();
    final colDiff = (col1 - col2).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }
  
  /// Calculate score based on match count and combo
  static int calculateScore(int matchCount, int comboMultiplier) {
    int baseScore = 0;
    
    if (matchCount == 3) {
      baseScore = 100;
    } else if (matchCount == 4) {
      baseScore = 200;
    } else if (matchCount >= 5) {
      baseScore = 400;
    }
    
    return baseScore * comboMultiplier;
  }
  
  /// Calculate stars based on score and target
  static int calculateStars(int score, int targetScore) {
    if (score >= targetScore * 2) {
      return 3;
    } else if (score >= targetScore * 1.5) {
      return 2;
    } else if (score >= targetScore) {
      return 1;
    }
    return 0;
  }
  
  /// Get gem color by type
  static int getGemColor(GemType type) {
    switch (type) {
      case GemType.red:
        return 0xFFFF0000;
      case GemType.blue:
        return 0xFF0000FF;
      case GemType.green:
        return 0xFF00FF00;
      case GemType.yellow:
        return 0xFFFFFF00;
      case GemType.purple:
        return 0xFFFF00FF;
      case GemType.cyan:
        return 0xFF00FFFF;
      case GemType.lightning:
        return 0xFFFFD700;
      case GemType.wings:
        return 0xFFFFFFFF;
      case GemType.temple:
        return 0xFFFFA500;
      case GemType.lyre:
        return 0xFF87CEEB;
    }
  }
  
  /// Format time (seconds to MM:SS)
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  /// Format score with thousands separator
  static String formatScore(int score) {
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
  
  /// Get level difficulty
  static GameDifficulty getLevelDifficulty(int level) {
    if (level <= 10) {
      return GameDifficulty.easy;
    } else if (level <= 25) {
      return GameDifficulty.medium;
    } else if (level <= 40) {
      return GameDifficulty.hard;
    }
    return GameDifficulty.olympus;
  }
  
  /// Calculate power cost based on difficulty
  static int getPowerCost(ZeusPower power, GameDifficulty difficulty) {
    int baseCost = 0;
    
    switch (power) {
      case ZeusPower.thunderStrike:
        baseCost = AppConstants.thunderStrikeCost;
        break;
      case ZeusPower.chainLightning:
        baseCost = AppConstants.chainLightningCost;
        break;
      case ZeusPower.skyWingsDash:
        baseCost = AppConstants.skyWingsCost;
        break;
      case ZeusPower.wrathOfOlympus:
        baseCost = AppConstants.wrathOfOlympusCost;
        break;
    }
    
    // Increase cost on harder difficulties
    switch (difficulty) {
      case GameDifficulty.easy:
        return baseCost;
      case GameDifficulty.medium:
        return (baseCost * 1.2).round();
      case GameDifficulty.hard:
        return (baseCost * 1.5).round();
      case GameDifficulty.olympus:
        return (baseCost * 2).round();
    }
  }
  
  /// Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
