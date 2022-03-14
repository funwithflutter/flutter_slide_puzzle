import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:forge2d/forge2d.dart';
import 'package:fun_with_flutter_slide_puzzle/box2d/box2d.dart';

class Box2DPaintDebug extends CustomPainter {
  Box2DPaintDebug({
    required this.animation,
    required this.box2d,
  })  : world = box2d.world,
        super(repaint: animation);

  Animation<double> animation;
  final Box2DFlutter box2d;
  final World world;
  static final _paintCircle = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;

  static final _paintRectangle = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    for (final body in world.bodies) {
      for (final fixture in body.fixtures) {
        if (fixture.shape is CircleShape) {
          final circle = fixture.shape as CircleShape;
          _drawCirle(canvas, body, circle.radius);
        } else if (fixture.shape is PolygonShape) {
          final shape = fixture.shape as PolygonShape;
          if (shape.vertices.length > 2) {
            _drawVertices(canvas, body, shape.vertices);
          }
        }
      }
    }
  }

  void _drawVertices(
    ui.Canvas canvas,
    Body body,
    List<Vector2> vertices,
  ) {
    canvas.drawVertices(
      ui.Vertices(VertexMode.triangleStrip, [
        ...vertices.map(
          (e) => box2d
              .coordWorldToPixelsOffset(body.position + e.rotate(body.angle)),
        ),
        box2d.coordWorldToPixelsOffset(
          body.position + vertices[0].rotate(body.angle),
        ) // close shape
      ]),
      BlendMode.src,
      _paintRectangle,
    );
  }

  void _drawCirle(ui.Canvas canvas, Body body, double radius) {
    canvas.drawCircle(
      box2d.coordWorldToPixelsOffset(body.position),
      box2d.scalarWorldToPixels(radius),
      _paintCircle,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

extension Vector2Extension on Vector2 {
  Offset offset(double canvasHeight) => Offset(x, canvasHeight - y);

  Vector2 rotate(double angle) => Vector2(
        x * cos(angle) - y * sin(angle),
        x * sin(angle) + y * cos(angle),
      );
}
