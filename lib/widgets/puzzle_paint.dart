import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:forge2d/forge2d.dart';
import 'package:fun_with_flutter_slide_puzzle/state/box2d_state.dart';

class PuzzlePaint extends CustomPainter {
  PuzzlePaint({
    required this.animation,
    required this.box2dState,
    required this.boxImage,
    required this.ballImage,
    required this.particlePixelSize,
  })  : boxImageOffset = Offset(boxImage.width / 2, boxImage.height / 2),
        ballImageOffset = Offset(ballImage.width / 2, ballImage.height / 2),
        super(repaint: animation);

  final Animation<double> animation;
  final Box2dState box2dState;
  final ui.Image boxImage;
  final ui.Image ballImage;
  static final imagePaint = Paint();
  final Offset boxImageOffset;
  final Offset ballImageOffset;
  final ValueNotifier<double> particlePixelSize;

  void _rotate(Canvas canvas, double cx, double cy, double angle) {
    canvas.translate(cx, cy);
    canvas.rotate(-angle);
    canvas.translate(-cx, -cy);
  }

  void _paintBoxes(Canvas canvas) {
    for (final box in box2dState.boxes) {
      canvas.save();
      final pos = box2dState.box2d.coordWorldToPixelsOffset(box.position);
      _rotate(canvas, pos.dx, pos.dy, box.angle);
      paintImage(
        canvas: canvas,
        rect: Rect.fromCenter(
            center: pos,
            width: particlePixelSize.value,
            height: particlePixelSize.value),
        image: boxImage,
      );
      // canvas.drawImage(
      //   boxImage,
      //   pos - boxImageOffset,
      //   imagePaint,
      // );
      canvas.restore();
    }
  }

  void _paintBalls(Canvas canvas) {
    for (final ball in box2dState.balls) {
      canvas.save();
      final pos = box2dState.box2d.coordWorldToPixelsOffset(ball.position);
      _rotate(canvas, pos.dx, pos.dy, ball.angle);
      paintImage(
        canvas: canvas,
        rect: Rect.fromCenter(
          center: pos,
          width: particlePixelSize.value,
          height: particlePixelSize.value,
        ),
        image: ballImage,
      );
      canvas.restore();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintBoxes(canvas);
    _paintBalls(canvas);
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
