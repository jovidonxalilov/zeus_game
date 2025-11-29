import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class InitGameEvent extends GameEvent {
  final int level;
  const InitGameEvent({this.level = 1});
  @override
  List<Object?> get props => [level];
}

class SwapGemsEvent extends GameEvent {
  final int row1, col1, row2, col2;
  const SwapGemsEvent(this.row1, this.col1, this.row2, this.col2);
  @override
  List<Object?> get props => [row1, col1, row2, col2];
}

class ProcessMatchesEvent extends GameEvent {
  const ProcessMatchesEvent();
}

class RestartGameEvent extends GameEvent {
  const RestartGameEvent();
}