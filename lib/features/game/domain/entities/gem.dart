import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum GemType {
  red,
  blue,
  green,
  yellow,
  purple,
  cyan,
  // Special gems from TZ combo rules
  lightning,    // 4-in-row creates this
  storm,        // 5-in-row creates this
  wings,        // L-shape creates this
  temple,       // T-shape creates this
}

enum SpecialGemType {
  none,
  lightning,
  storm,
  wings,
  temple,
}

class Gem extends Equatable {
  final String id;
  final GemType type;
  final int row;
  final int col;
  final bool isMatched;
  final bool isAnimating;
  final SpecialGemType specialType;

  const Gem({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    this.isMatched = false,
    this.isAnimating = false,
    this.specialType = SpecialGemType.none,
  });

  bool get isSpecial => specialType != SpecialGemType.none;

  Gem copyWith({
    String? id,
    GemType? type,
    int? row,
    int? col,
    bool? isMatched,
    bool? isAnimating,
    SpecialGemType? specialType,
  }) {
    return Gem(
      id: id ?? this.id,
      type: type ?? this.type,
      row: row ?? this.row,
      col: col ?? this.col,
      isMatched: isMatched ?? this.isMatched,
      isAnimating: isAnimating ?? this.isAnimating,
      specialType: specialType ?? this.specialType,
    );
  }

  Color get color {
    switch (type) {
      case GemType.red:
        return const Color(0xFFE53935);
      case GemType.blue:
        return const Color(0xFF1E88E5);
      case GemType.green:
        return const Color(0xFF43A047);
      case GemType.yellow:
        return const Color(0xFFFFB300);
      case GemType.purple:
        return const Color(0xFF8E24AA);
      case GemType.cyan:
        return const Color(0xFF00ACC1);
      case GemType.lightning:
        return const Color(0xFF00BFFF);
      case GemType.storm:
        return const Color(0xFFFFD700);
      case GemType.wings:
        return const Color(0xFF9C27B0);
      case GemType.temple:
        return const Color(0xFFFF6F00);
    }
  }

  @override
  List<Object?> get props => [id, type, row, col, isMatched, isAnimating, specialType];
}