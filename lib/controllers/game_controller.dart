import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../state/state.dart';

final gameControllerProvider =
    StateNotifierProvider<GameController, GameState>((ref) {
  final controller = GameController(ref.read, ticker: const Ticker());
  ref.listen<PuzzleStatus>(
    puzzleStatusProvider,
    (previous, next) {
      if (next == PuzzleStatus.complete) {
        controller.setGameFinished();
      }
    },
  );
  return controller;
});

class GameController extends StateNotifier<GameState> {
  GameController(
    this._read, {
    required Ticker ticker,
  })  : _ticker = ticker,
        super(const GameState());

  final Reader _read;
  final Ticker _ticker;

  StreamSubscription<int>? _tickerSubscription;

  void _startTicker() {
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick().listen((val) => _onTick(val));
  }

  void _stopTicker() {
    _tickerSubscription?.cancel();
  }

  void _onTick(int val) {
    state = state.copyWith(gameTime: val);
  }

  /// Start a new game.
  void start() {
    state = state.copyWith(
      gameStateStatus: GameStateStatus.started,
      gameTime: 0,
    );
    _startTicker();
    _read(Providers.puzzleController.notifier).resetPuzzle();
    final box2dController = _read(Providers.box2dController.notifier);
    box2dController.reset(_read(Providers.puzzleController).puzzle);
    box2dController.makeItRain(loop: true);
  }

  void addOneSecondTimePenalty() {
    state = state.copyWith(
      currentTimePenalty: state.currentTimePenalty + const Duration(seconds: 1),
    );
  }

  void makeItRainAndSpeedUpTimer({bool loop = true}) {
    state = state.copyWith(
      currentTimePenalty:
          state.currentTimePenalty + const Duration(milliseconds: 100),
    );
    _read(Providers.box2dController.notifier).makeItRain(loop: false);
  }

  Future<void> addPenaltyToTime() async {
    final total = state.currentTimePenalty.inSeconds;
    for (var i = 0; i < total; i++) {
      state = state.copyWith(
        totalTimePenalty: state.totalTimePenalty + 1,
        currentTimePenalty:
            state.currentTimePenalty - const Duration(seconds: 1),
      );
      await Future.delayed(const Duration(milliseconds: 100));
    }
    state = state.copyWith(currentTimePenalty: Duration.zero);
  }

  /// Reset the game board and state.
  void reset() {
    _stopTicker();
    state = const GameState();
    _read(Providers.puzzleController.notifier).initializePuzzle(
      shuffle: false,
    );
    _read(Providers.box2dController.notifier).reset(
      _read(Providers.puzzleController).puzzle,
    );
  }

  void forceAWin() {
    _read(Providers.puzzleController.notifier).forceComplete();
    setGameFinished();
  }

  void setGameFinished() {
    _stopTicker();
    _read(Providers.box2dController.notifier).performWinAnimation();
    state = state.copyWith(gameStateStatus: GameStateStatus.finished);
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    super.dispose();
  }
}
