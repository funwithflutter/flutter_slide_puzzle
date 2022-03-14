import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fun_with_flutter_slide_puzzle/controllers/controllers.dart';
import 'package:fun_with_flutter_slide_puzzle/state/state.dart';

/// [GameStateStatus] provider.
final gameStateStatusProvider = Provider<GameStateStatus>(
  (ref) => ref.watch(gameControllerProvider).gameStateStatus,
);

/// [PuzzleStatus] provider.
final puzzleStatusProvider = Provider<PuzzleStatus>(
  (ref) => ref.watch(puzzleControllerProvider).puzzleStatus,
);

abstract class Providers {
  static StateNotifierProvider<GameController, GameState> get gameController =>
      gameControllerProvider;

  static StateNotifierProvider<PuzzleController, PuzzleState>
      get puzzleController => puzzleControllerProvider;

  static StateNotifierProvider<Box2DController, Box2dState>
      get box2dController => box2DControllerProvider;

  static StateNotifierProvider<ConfigController, ConfigState>
      get configController => configControllerProvider;

  static Provider<GameStateStatus> get gameStateStatus =>
      gameStateStatusProvider;

  static Provider<PuzzleStatus> get puzzleStatus => puzzleStatusProvider;
}
