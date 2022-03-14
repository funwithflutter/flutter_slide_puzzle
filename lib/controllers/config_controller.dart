import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fun_with_flutter_slide_puzzle/providers/providers.dart';
import 'package:fun_with_flutter_slide_puzzle/state/config_state.dart';

final configControllerProvider =
    StateNotifierProvider<ConfigController, ConfigState>((ref) {
  return ConfigController(ref.read);
});

class ConfigController extends StateNotifier<ConfigState> {
  ConfigController(this._read) : super(const ConfigState());
  final Reader _read;

  void updateGravity(double gravity) {
    state = state.copyWith(gravity: gravity);
    _read(Providers.box2dController).setGravity(gravity);
  }

  void updateBallDensity(double density) {
    state = state.copyWith(ballDensity: density);
    _read(Providers.box2dController).setBallDensity(density);
  }

  void updateBallRestitution(double resititution) {
    state = state.copyWith(ballRestitution: resititution);
    _read(Providers.box2dController).setBallRestitution(resititution);
  }

  void updateBoxDensity(double density) {
    state = state.copyWith(boxDensity: density);
    _read(Providers.box2dController).setBoxDensity(density);
  }

  void updateBoxRestitution(double resititution) {
    state = state.copyWith(boxRestitution: resititution);
    _read(Providers.box2dController).setBoxRestitution(resititution);
  }

  void reset() {
    state = const ConfigState();
  }
}
