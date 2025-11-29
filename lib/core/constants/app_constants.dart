import 'package:flutter/material.dart';

/// App constants - barcha doimiy qiymatlar
class AppConstants {
  // App Info
  static const String appName = 'ZEUS - Rise of Olympus';
  static const String appVersion = '1.0.0';

  // Grid Settings
  static const int gridRows = 7;
  static const int gridColumns = 6;
  static const double gemSize = 50.0;
  static const double gemSpacing = 4.0;

  // Animation Durations
  static const Duration swapDuration = Duration(milliseconds: 300);
  static const Duration fallDuration = Duration(milliseconds: 400);
  static const Duration matchDuration = Duration(milliseconds: 500);
  static const Duration explosionDuration = Duration(milliseconds: 600);

  // Game Settings
  static const int movesPerLevel = 30;
  static const int targetScore = 1000;
  static const int comboMultiplier = 2;

  // Powers Cost
  static const int thunderStrikeCost = 3;
  static const int chainLightningCost = 5;
  static const int skyWingsCost = 4;
  static const int wrathOfOlympusCost = 10;

  // Colors
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color secondaryOrange = Color(0xFFFF8C00);
  static const Color electricBlue = Color(0xFF00BFFF);
  static const Color marbleWhite = Color(0xFFF5F5DC);
  static const Color darkPurple = Color(0xFF4B0082);
  static const Color shadowBlack = Color(0xFF1A1A1A);

  // Gem Colors
  static const List<Color> gemColors = [
    Color(0xFFFF0000), // Red
    Color(0xFF0000FF), // Blue
    Color(0xFF00FF00), // Green
    Color(0xFFFFFF00), // Yellow
    Color(0xFFFF00FF), // Purple
    Color(0xFF00FFFF), // Cyan
  ];
}

/// Game gem types
enum GemType {
  red,
  blue,
  green,
  yellow,
  purple,
  cyan,
  lightning,
  wings,
  temple,
  lyre,
}

/// Zeus powers
enum ZeusPower {
  thunderStrike,
  chainLightning,
  skyWingsDash,
  wrathOfOlympus,
}

/// Game difficulty
enum GameDifficulty {
  easy,
  medium,
  hard,
  olympus,
}

/// Level status
enum LevelStatus {
  locked,
  unlocked,
  completed,
  perfect,
}
