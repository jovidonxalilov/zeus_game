import 'package:equatable/equatable.dart';
import 'package:zeus_game/core/constants/app_constants.dart';

/// Base game event
abstract class GameEvent extends Equatable {
  const GameEvent();
  
  @override
  List<Object?> get props => [];
}

/// Initialize game
class InitializeGameEvent extends GameEvent {
  final int level;
  
  const InitializeGameEvent(this.level);
  
  @override
  List<Object?> get props => [level];
}

/// Swap gems
class SwapGemsEvent extends GameEvent {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  
  const SwapGemsEvent({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
  });
  
  @override
  List<Object?> get props => [fromRow, fromCol, toRow, toCol];
}

/// Use Zeus power
class UseZeusPowerEvent extends GameEvent {
  final ZeusPower power;
  final int? targetRow;
  final int? targetCol;
  
  const UseZeusPowerEvent({
    required this.power,
    this.targetRow,
    this.targetCol,
  });
  
  @override
  List<Object?> get props => [power, targetRow, targetCol];
}

/// Process matches
class ProcessMatchesEvent extends GameEvent {
  const ProcessMatchesEvent();
}

/// Fill empty spaces
class FillEmptySpacesEvent extends GameEvent {
  const FillEmptySpacesEvent();
}

/// Reset combo
class ResetComboEvent extends GameEvent {
  const ResetComboEvent();
}

/// Pause game
class PauseGameEvent extends GameEvent {
  const PauseGameEvent();
}

/// Resume game
class ResumeGameEvent extends GameEvent {
  const ResumeGameEvent();
}

/// Restart game
class RestartGameEvent extends GameEvent {
  const RestartGameEvent();
}

/// Game over
class GameOverEvent extends GameEvent {
  final bool isVictory;
  
  const GameOverEvent(this.isVictory);
  
  @override
  List<Object?> get props => [isVictory];
}
