import 'package:equatable/equatable.dart';
import '../../domain/model/state_model.dart';

abstract class GameState extends Equatable {
  const GameState();
  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {
  const GameInitial();
}

class GameLoading extends GameState {
  const GameLoading();
}

class GameReady extends GameState {
  final GameStateModel gameState;
  const GameReady(this.gameState);
  @override
  List<Object?> get props => [gameState];
}

class GameProcessing extends GameState {
  final GameStateModel gameState;
  const GameProcessing(this.gameState);
  @override
  List<Object?> get props => [gameState];
}

class GameWon extends GameState {
  final GameStateModel gameState;
  const GameWon(this.gameState);
  @override
  List<Object?> get props => [gameState];
}

class GameLost extends GameState {
  final GameStateModel gameState;
  const GameLost(this.gameState);
  @override
  List<Object?> get props => [gameState];
}

class GameError extends GameState {
  final String message;
  const GameError(this.message);
  @override
  List<Object?> get props => [message];
}