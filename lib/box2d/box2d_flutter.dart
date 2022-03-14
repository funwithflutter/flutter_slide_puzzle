import 'dart:ui';

import 'package:forge2d/forge2d.dart';

/// A wrapper to help intergrate Box2D in Flutter.
class Box2DFlutter {
  Box2DFlutter(Size pixelSize, {double scaleFactor = 1})
      : _size = pixelSize,
        _transX = pixelSize.width,
        _transY = pixelSize.height,
        _scaleFactor = scaleFactor;

  late final World world;

  Size _size;
  double _transX;
  double _transY;
  double _scaleFactor;
  static const double _yFlip = -1;

  Size get size => _size;
  double get transX => _transX;
  double get transY => _transY;
  double get scaleFactor => _scaleFactor;

  /// Change the pixel size [transX] and [transY].
  set size(Size s) {
    _size = s;
    _transX = s.width;
    _transY = s.height;
  }

  /// Change the [scaleFactor].
  set scaleFactor(double sf) {
    _scaleFactor = sf;
  }

  void createWorld({Vector2? gravity, BroadPhase? broadPhase}) {
    world = World(gravity, broadPhase);
  }

  /// Convert Coordinate from Box2d world to pixel space.
  Vector2 coordWorldToPixels(double worldX, double worldY) {
    // final pixelX = _lerpVector(worldX, 0, 1, 0, transX);
    final pixelX =
        _lerpVector(worldX, 0, 1, transX, transX + scaleFactor) - size.width;
    var pixelY = _lerpVector(worldY, 0, 1, transY, transY + scaleFactor);
    // var pixelY = _lerpVector(worldY, 0, 1, 0, transY);
    // final pixelX = _lerpVector(worldX, 0, 1, transX, transX);
    // var pixelY = _lerpVector(worldY, 0, 1, transY, transY);

    if (_yFlip == -1) {
      pixelY = _lerpVector(pixelY, 0, size.height, size.height, 0);
    }

    return Vector2(pixelX, pixelY);
  }

  /// Convert Coordinate from Box2d world to pixel space, as an [Offset].
  Offset coordWorldToPixelsOffset(Vector2 v) {
    final pixels = coordWorldToPixels(v.x, v.y);
    return Offset(pixels.x, pixels.y);
  }

  /// Convert Coordinate from pixel space to box2d world.
  Vector2 coordPixelsToWorld(double pixelX, double pixelY) {
    final worldX = _lerpVector(pixelX, transX, transX + scaleFactor, 0, 1);
    var worldY = (_yFlip == -1)
        ? _lerpVector(pixelY, size.height, 0, 0, size.height)
        : pixelY;
    worldY = _lerpVector(worldY, transY, transY + scaleFactor, 0, 1);
    return Vector2(worldX, worldY);
  }

  // public Vec2 coordPixelsToWorld(float pixelX, float pixelY) {
  // 	float worldX = PApplet.map(pixelX, transX, transX+scaleFactor, 0f, 1f);
  // 	float worldY = pixelY;
  // 	if (yFlip == -1.0f) worldY = PApplet.map(pixelY,parent.height,0f,0f,parent.height);
  // 	worldY = PApplet.map(worldY, transY, transY+scaleFactor, 0f, 1f);
  // 	return new Vec2(worldX,worldY);
  // }

  // Scale scalar quantity between worlds.
  double scalarPixelsToWorld(double val) {
    return val / _scaleFactor;
  }

  double scalarWorldToPixels(double val) {
    return val * _scaleFactor;
  }

  double _lerpVector(
      double value, double iStart, double iStop, double oStart, double oStop) {
    return oStart + (oStop - oStart) * ((value - iStart) / (iStop - iStart));
  }
}
