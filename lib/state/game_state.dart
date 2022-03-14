import 'package:equatable/equatable.dart';

enum GameStateStatus {
  /// The puzzle is not started yet.
  notStarted,

  /// The puzzle is loading.
  loading,

  /// The puzzle is started.
  started,

  /// The puzzle is finished.
  finished
}

class GameState extends Equatable {
  const GameState({
    this.gameStateStatus = GameStateStatus.notStarted,
    this.gameTime = 0,
    this.currentTimePenalty = Duration.zero,
    this.totalTimePenalty = 0,
  });

  /// The game state status.
  final GameStateStatus gameStateStatus;

  /// The amount of time this game has lasted.
  final int gameTime;

  final Duration currentTimePenalty;

  final int totalTimePenalty;

  @override
  List<Object> get props => [gameStateStatus, gameTime];

  GameState copyWith({
    GameStateStatus? gameStateStatus,
    int? gameTime,
    Duration? currentTimePenalty,
    int? totalTimePenalty,
  }) {
    return GameState(
      gameStateStatus: gameStateStatus ?? this.gameStateStatus,
      gameTime: gameTime ?? this.gameTime,
      currentTimePenalty: currentTimePenalty ?? this.currentTimePenalty,
      totalTimePenalty: totalTimePenalty ?? this.totalTimePenalty,
    );
  }
}
