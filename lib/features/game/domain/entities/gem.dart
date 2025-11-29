import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum GemType { red, blue, green, yellow, purple, cyan }

class Gem extends Equatable {
  final String id;
  final GemType type;
  final int row;
  final int col;
  final bool isMatched;
  final bool isAnimating;

  const Gem({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    this.isMatched = false,
    this.isAnimating = false,
  });

  Gem copyWith({
    String? id,
    GemType? type,
    int? row,
    int? col,
    bool? isMatched,
    bool? isAnimating,
  }) {
    return Gem(
      id: id ?? this.id,
      type: type ?? this.type,
      row: row ?? this.row,
      col: col ?? this.col,
      isMatched: isMatched ?? this.isMatched,
      isAnimating: isAnimating ?? this.isAnimating,
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
    }
  }

  @override
  List<Object?> get props => [id, type, row, col, isMatched, isAnimating];
}