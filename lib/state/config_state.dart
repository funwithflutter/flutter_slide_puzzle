import 'package:equatable/equatable.dart';
import 'package:fun_with_flutter_slide_puzzle/box2d/box2d.dart';

class ConfigState extends Equatable {
  final double gravity;
  final double ballDensity;
  final double ballRestitution;
  final double boxDensity;
  final double boxRestitution;

  const ConfigState({
    this.gravity = defaultGravity,
    this.ballDensity = defaultBallDensity,
    this.ballRestitution = defaultBallRestitution,
    this.boxDensity = defaultBoxDensity,
    this.boxRestitution = defaultBoxRestitution,
  });

  @override
  List<Object?> get props => [gravity];

  ConfigState copyWith({
    double? gravity,
    double? ballDensity,
    double? ballRestitution,
    double? boxDensity,
    double? boxRestitution,
  }) =>
      ConfigState(
        gravity: gravity ?? this.gravity,
        ballDensity: ballDensity ?? this.ballDensity,
        ballRestitution: ballRestitution ?? this.ballRestitution,
        boxDensity: boxDensity ?? this.boxDensity,
        boxRestitution: boxRestitution ?? this.boxRestitution,
      );
}
