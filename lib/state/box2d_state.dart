import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge2d/forge2d.dart';
import 'package:fun_with_flutter_slide_puzzle/box2d/box2d.dart';

import '../models/models.dart';
import '../providers/providers.dart';

class Box2dState {
  static final math.Random _random = math.Random();

  /// Get the Box2D world.
  World get world => box2d.world;

  /// All of the ball bodies in the simulation.
  final List<Body> balls = <Body>[];

  /// ALl of the box bodies in the simulation.
  final List<Body> boxes = <Body>[];

  /// Map collection of the play cubes
  Map<int, Body> playCubes = {};

  final Reader _read;

  final Puzzle puzzle;
  Size pixelSize;
  double scaleFactor;
  late Box2DFlutter box2d = Box2DFlutter(pixelSize, scaleFactor: scaleFactor);

  Box2dState(
    this.puzzle,
    this._read, {
    required this.pixelSize,
    required this.scaleFactor,
  }) {
    _initialize(puzzle);
  }

  void _initialize(Puzzle puzzle) {
    box2d.createWorld(
        gravity: Vector2(0, _read(Providers.configController).gravity));
    world.setAllowSleep(true);
    _createBoard(puzzle);
  }

  void _createBoard(Puzzle puzzle) {
    for (final tile in puzzle.tiles) {
      if (tile.value == puzzle.tiles.length) {
        continue;
      }

      final pos = tile.currentPosition;

      final factor = boardSizeSide / puzzle.dimension;
      playCubes[tile.value] = _createPlayCubeBody(
          Vector2((pos.x - 1) * factor, -(pos.y - 1) * factor));
    }
  }

  /// Open box with angled sides used as the play cube to catch balls and boxes.
  ///
  /// [BodyType.kinematic]
  Body _createPlayCubeBody(Vector2 position) {
    final bodyDef = BodyDef()
      ..position = position
      ..type = BodyType.kinematic
      ..bullet = true;

    final body = world.createBody(bodyDef);

    const borderWidth = 1.0;
    const overallSize = 25.0;
    const padding = overallSize / paddingRatio;
    const borderWidthAndPadding = borderWidth * 2 + padding;
    const boxSize = overallSize / 2 - padding;
    const centerPosition = overallSize / 2;
    const halfSizeExcludingBorder = boxSize - borderWidth;
    const angledSideSize = boxSize / 4;
    const positionExcludingBorderAndPadding =
        overallSize - borderWidthAndPadding;

    final shape = PolygonShape();

    // Bottom
    shape.setAsBox(
      halfSizeExcludingBorder,
      borderWidth,
      Vector2(centerPosition, -positionExcludingBorderAndPadding),
      0,
    );
    body.createFixtureFromShape(shape);

    // Left angled scoop
    shape.setAsBox(angledSideSize, borderWidth,
        Vector2(angledSideSize * 1.1, -angledSideSize * 0.9), -math.pi / 4);
    body.createFixtureFromShape(shape);

    // Right angled scoop
    shape.setAsBox(
        angledSideSize,
        borderWidth,
        Vector2(overallSize - angledSideSize * 1.1, -angledSideSize * 0.9),
        math.pi / 4);
    body.createFixtureFromShape(shape);

    // Left side
    shape.setAsBox(
      borderWidth,
      halfSizeExcludingBorder,
      Vector2(borderWidthAndPadding, -centerPosition),
      0,
    );
    body.createFixtureFromShape(shape);

    // Right side
    shape.setAsBox(
      borderWidth,
      halfSizeExcludingBorder,
      Vector2(positionExcludingBorderAndPadding, -centerPosition),
      0,
    );
    body.createFixtureFromShape(shape);

    return body;
  }

  /// Creates a ball with a [BodyType.dynamic].
  void _createBall() {
    final shape = CircleShape()..radius = particleWorldSize / 2;

    final activeFixtureDef = FixtureDef(shape)
      ..restitution = _read(Providers.configController).ballRestitution
      ..density = _read(Providers.configController).ballDensity;

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(
        _random.nextInt(100).toDouble(),
        5 + _random.nextInt(100).toDouble(),
      )
      ..angle = lerpDouble(-pi / 2, pi / 2, _random.nextDouble())!;

    final fallingBox = world.createBody(bodyDef)
      ..createFixture(activeFixtureDef);

    balls.add(fallingBox);
  }

  /// Creates a box with a [BodyType.dynamic].
  void _createBox() {
    final shape = PolygonShape()
      ..setAsBox(
        particleWorldSize / 2,
        particleWorldSize / 2,
        Vector2(0, 0),
        0,
      );

    final activeFixtureDef = FixtureDef(shape)
      ..restitution = _read(Providers.configController).boxRestitution
      ..density = _read(Providers.configController).boxDensity;

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(
          _random.nextInt(100).toDouble(), 5 + _random.nextInt(100).toDouble())
      ..angle = lerpDouble(-pi / 2, pi / 2, _random.nextDouble())!;

    final fallingBox = world.createBody(bodyDef)
      ..createFixture(activeFixtureDef);

    boxes.add(fallingBox);
  }

  /// Destroy bodies that are no longer contained in the world size height.
  void _destroyBodies() {
    const destroyHeight = boardSizeSide * 2;
    // Get all balls to dispose
    final ballsToDispose = <Body>[];
    for (final body in balls) {
      if (body.position.y < -destroyHeight) {
        ballsToDispose.add(body);
      }
    }
    // Get all boxes to dispose
    final boxesToDispose = <Body>[];
    for (final body in boxes) {
      if (body.position.y < -destroyHeight) {
        boxesToDispose.add(body);
      }
    }

    // Dispose all balls
    for (final body in ballsToDispose) {
      balls.remove(body);
      world.destroyBody(body);
    }

    // Dispose all boxes
    for (final body in boxesToDispose) {
      boxes.remove(body);
      world.destroyBody(body);
    }
  }

  void reset(Puzzle puzzle) {
    box2d = Box2DFlutter(pixelSize, scaleFactor: scaleFactor);
    balls.clear;
    boxes.clear;
    playCubes.clear;
    _initialize(puzzle);
  }

  /// Update box2d world size and scale factor.
  void updateWorldSizeFromPixelSize(Size size) {
    final smallest = math.min(size.width, size.height);
    pixelSize = size;
    scaleFactor = smallest / boardSizeWorld.width;
    box2d
      ..size = pixelSize
      ..scaleFactor = scaleFactor;
  }

  /// Make it rain boxes and balls.
  Future<void> makeItRain({required bool loop}) async {
    if (loop) {
      for (var i = 0; i < 100; i++) {
        _createBall();
        _createBox();
        _createBall();
        _createBox();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } else {
      _createBall();
      _createBox();
    }
  }

  void setGravity(double gravity) {
    world.setGravity(Vector2(0, gravity));
  }

  void setBallDensity(double density) {
    for (var ball in balls) {
      for (var fixture in ball.fixtures) {
        fixture.density = density;
      }
    }
  }

  void setBallRestitution(double restitution) {
    for (var ball in balls) {
      for (var fixture in ball.fixtures) {
        fixture.restitution = restitution;
      }
    }
  }

  void setBoxDensity(double density) {
    for (var box in boxes) {
      for (var fixture in box.fixtures) {
        fixture.density = density;
      }
    }
  }

  void setBoxRestitution(double restitution) {
    for (var box in boxes) {
      for (var fixture in box.fixtures) {
        fixture.restitution = restitution;
      }
    }
  }

  void flipTheWorld() {
    world.setGravity(Vector2(7, 20));
  }

  /// Update box2d state and do a world step.
  void update() {
    world.stepDt(timeStep);
    if ((boxes.length + balls.length) > 300) {
      _destroyBodies();
    }
  }

  /// Update the position of a specific play cube.
  void updatePlayCubePosition({
    required int cube,
    required Vector2 position,
    required Vector2 linearVelocity,
  }) {
    if (cube == 16) return;
    playCubes[cube]!.linearVelocity = linearVelocity;
    playCubes[cube]!.setTransform(position, playCubes[cube]!.angle);
  }

  Box2dState copyWith({
    Puzzle? puzzle,
    Size? pixelSize,
    double? scaleFactor,
  }) {
    return Box2dState(
      puzzle ?? this.puzzle,
      _read,
      pixelSize: pixelSize ?? this.pixelSize,
      scaleFactor: scaleFactor ?? this.scaleFactor,
    );
  }
}
