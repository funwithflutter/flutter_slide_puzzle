import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fun_with_flutter_slide_puzzle/state/state.dart';

import '../box2d/constants.dart';
import '../models/models.dart';
import '../providers/providers.dart';

final box2DControllerProvider =
    StateNotifierProvider<Box2DController, Box2dState>(
  (ref) => Box2DController(
    ref.read(Providers.puzzleController).puzzle,
    ref.read,
  ),
);

class Box2DController extends StateNotifier<Box2dState> {
  Box2DController(
    Puzzle puzzle,
    Reader reader,
  ) : super(
          Box2dState(
            puzzle,
            reader,
            pixelSize: defaultBoardSizePixels,
            scaleFactor: defaultBoardSizePixels.width / boardSizeWorld.width,
          ),
        );

  void reset(Puzzle puzzle) {
    state = state.copyWith(
      puzzle: puzzle,
    );
  }

  void update() {
    state.update();
  }

  void makeItRain({required bool loop}) {
    state.makeItRain(loop: loop);
  }

  void performWinAnimation() {
    state.flipTheWorld();
  }
}
