import 'package:equatable/equatable.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/level.dart';

/// Base game BLoC state
abstract class GameBlocState extends Equatable {
  const GameBlocState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class GameInitial extends GameBlocState {
  const GameInitial();
}

/// Loading state
class GameLoading extends GameBlocState {
  const GameLoading();
}

/// Playing state
class GamePlaying extends GameBlocState {
  final GameState gameState;
  final Level level;
  
  const GamePlaying({
    required this.gameState,
    required this.level,
  });
  
  @override
  List<Object?> get props => [gameState, level];
}

/// Processing state (animations, matches)
class GameProcessing extends GameBlocState {
  final GameState gameState;
  final Level level;
  final String? message;
  
  const GameProcessing({
    required this.gameState,
    required this.level,
    this.message,
  });
  
  @override
  List<Object?> get props => [gameState, level, message];
}

/// Paused state
class GamePaused extends GameBlocState {
  final GameState gameState;
  final Level level;
  
  const GamePaused({
    required this.gameState,
    required this.level,
  });
  
  @override
  List<Object?> get props => [gameState, level];
}

/// Game over state
class GameOver extends GameBlocState {
  final GameState gameState;
  final Level level;
  final bool isVictory;
  final int stars;
  final int finalScore;
  
  const GameOver({
    required this.gameState,
    required this.level,
    required this.isVictory,
    required this.stars,
    required this.finalScore,
  });
  
  @override
  List<Object?> get props => [gameState, level, isVictory, stars, finalScore];
}

/// Error state
class GameError extends GameBlocState {
  final String message;
  
  const GameError(this.message);
  
  @override
  List<Object?> get props => [message];
}
