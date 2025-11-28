import 'package:equatable/equatable.dart';
import 'package:zeus_game/core/constants/app_constants.dart';

/// Gem entity - o'yin maydonidagi tosh
class Gem extends Equatable {
  final String id;
  final GemType type;
  final int row;
  final int column;
  final bool isMatched;
  final bool isSpecial;
  final bool isFalling;
  
  const Gem({
    required this.id,
    required this.type,
    required this.row,
    required this.column,
    this.isMatched = false,
    this.isSpecial = false,
    this.isFalling = false,
  });
  
  /// Copy with method
  Gem copyWith({
    String? id,
    GemType? type,
    int? row,
    int? column,
    bool? isMatched,
    bool? isSpecial,
    bool? isFalling,
  }) {
    return Gem(
      id: id ?? this.id,
      type: type ?? this.type,
      row: row ?? this.row,
      column: column ?? this.column,
      isMatched: isMatched ?? this.isMatched,
      isSpecial: isSpecial ?? this.isSpecial,
      isFalling: isFalling ?? this.isFalling,
    );
  }
  
  /// Check if gem is special type
  bool get isSpecialGem {
    return type == GemType.lightning ||
        type == GemType.wings ||
        type == GemType.temple ||
        type == GemType.lyre;
  }
  
  @override
  List<Object?> get props => [id, type, row, column, isMatched, isSpecial, isFalling];
  
  @override
  String toString() {
    return 'Gem(id: $id, type: $type, row: $row, col: $column, matched: $isMatched)';
  }
}
