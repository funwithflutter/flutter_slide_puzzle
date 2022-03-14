import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge2d/forge2d.dart' hide Transform;
import 'package:fun_with_flutter_slide_puzzle/box2d/box2d.dart';
import 'package:fun_with_flutter_slide_puzzle/controllers/controllers.dart';
import 'package:fun_with_flutter_slide_puzzle/models/models.dart';
import 'package:fun_with_flutter_slide_puzzle/providers/providers.dart';
import 'package:fun_with_flutter_slide_puzzle/state/game_state.dart';

class PuzzleTile extends ConsumerStatefulWidget {
  const PuzzleTile({
    Key? key,
    required this.tile,
    required this.dimension,
    required this.size,
  }) : super(key: key);

  final Tile tile;
  final int dimension;
  final Size size;

  @override
  ConsumerState<PuzzleTile> createState() => _PuzzleTileState();
}

class _PuzzleTileState extends ConsumerState<PuzzleTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  late final initialAlignment = FractionalOffset(
    (widget.tile.currentPosition.x - 1) / (widget.dimension - 1),
    (widget.tile.currentPosition.y - 1) / (widget.dimension - 1),
  );

  late final alignTween = Tween<Alignment>(
    begin: initialAlignment,
    end: initialAlignment,
  );

  late final Animation<Alignment> alignmentAnimation = alignTween.animate(
    CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    ),
  );

  late final _ratio = boardSizeWorld.width / widget.dimension;
  late final initialPosition = Offset(
    (widget.tile.currentPosition.x - 1) * _ratio,
    (widget.tile.currentPosition.y - 1) * _ratio,
  );

  late final positionTween =
      Tween<Offset>(begin: initialPosition, end: initialPosition);

  late final Animation<Offset> positionAnimation = positionTween.animate(
    CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    ),
  );

  late Vector2 previousValue = Vector2(initialPosition.dx, -initialPosition.dy);

  @override
  void initState() {
    super.initState();
    animationController.addListener(_updatePlayCubePositionListener);
  }

  void _updatePlayCubePositionListener() {
    final worldPosition =
        Vector2(positionAnimation.value.dx, positionAnimation.value.dy);
    final velocityDiff = worldPosition - previousValue;
    ref.read(box2DControllerProvider).updatePlayCubePosition(
          cube: widget.tile.value,
          position: Vector2(worldPosition.x, -worldPosition.y),
          linearVelocity:
              (animationController.status == AnimationStatus.completed)
                  ? Vector2.zero()
                  : Vector2(
                      velocityDiff.x / timeStep, -(velocityDiff.y / timeStep)),
        );
    previousValue = worldPosition;
  }

  @override
  void dispose() {
    animationController.removeListener(_updatePlayCubePositionListener);
    animationController.dispose();
    super.dispose();
  }

  void onTap() {
    final gameStatus = ref.read(Providers.gameStateStatus);
    if (gameStatus == GameStateStatus.started) {
      ref.read(Providers.puzzleController.notifier).tapTile(widget.tile);
    }
  }

  @override
  void didUpdateWidget(covariant PuzzleTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tile != widget.tile) {
      alignTween.begin = FractionalOffset(
        (oldWidget.tile.currentPosition.x - 1) / (oldWidget.dimension - 1),
        (oldWidget.tile.currentPosition.y - 1) / (oldWidget.dimension - 1),
      );

      alignTween.end = FractionalOffset(
        (widget.tile.currentPosition.x - 1) / (widget.dimension - 1),
        (widget.tile.currentPosition.y - 1) / (oldWidget.dimension - 1),
      );

      final offset = Offset(
        (oldWidget.tile.currentPosition.x - 1) * _ratio,
        (oldWidget.tile.currentPosition.y - 1) * _ratio,
      );
      positionTween.begin = offset;
      previousValue = Vector2(offset.dx, offset.dy);

      positionTween.end = Offset(
        (widget.tile.currentPosition.x - 1) * _ratio,
        (widget.tile.currentPosition.y - 1) * _ratio,
      );

      animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tile.isWhitespace) return const SizedBox();

    return AlignTransition(
      alignment: alignmentAnimation,
      child: GestureDetector(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints.tight(widget.size),
          child: Transform.translate(
            offset: Offset(0, -widget.size.width / paddingRatio * 0.8),
            child: Padding(
              padding: EdgeInsets.zero,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  'assets/images/${widget.tile.value}.png',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
