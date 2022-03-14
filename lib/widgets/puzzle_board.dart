import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fun_with_flutter_slide_puzzle/box2d/box2d.dart';
import 'package:fun_with_flutter_slide_puzzle/models/models.dart';
import 'package:fun_with_flutter_slide_puzzle/providers/providers.dart';
import 'package:fun_with_flutter_slide_puzzle/theme.dart';
import 'package:fun_with_flutter_slide_puzzle/widgets/puzzle_paint.dart';
import 'package:fun_with_flutter_slide_puzzle/widgets/widgets.dart';

import '../helpers/helpers.dart';
import '../state/state.dart';

final puzzleProvider = Provider<Puzzle>((ref) {
  return ref.watch(Providers.puzzleController).puzzle;
});

const paddingRatio = 0.05;

class PuzzleBoard extends ConsumerWidget {
  const PuzzleBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzle = ref.watch(puzzleProvider);
    final dimension = puzzle.dimension;
    final boardSizeWithPadding = defaultBoardSizePixels * (1 + paddingRatio);
    return ConstrainedBox(
      constraints: BoxConstraints.loose(boardSizeWithPadding),
      child: LayoutBuilder(
        builder: (context, constraint) {
          final minSize = math.min(constraint.maxHeight, constraint.maxWidth);
          final paddingSize = minSize * paddingRatio;
          return Container(
            decoration: BoxDecoration(
              color: AppColors.boardBackgroundColor,
              borderRadius: BorderRadius.all(
                Radius.circular(
                  minSize * 0.04,
                ),
              ),
              border: Border.all(
                color: Colors.black,
                width: minSize * 0.015,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(paddingSize),
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(defaultBoardSizePixels),
                child: LayoutBuilder(builder: (context, constraints) {
                  final smallest =
                      math.min(constraints.maxWidth, constraints.maxHeight);
                  final size = smallest / dimension;
                  return SizedBox(
                    width: smallest,
                    height: smallest,
                    child: Stack(
                      children: [
                        ParticlePuzzleBoard(
                          boardSizePixels: constraints.biggest,
                        ),
                        ...puzzle.tiles.map(
                          (tile) => PuzzleTile(
                            key: Key('puzzle_tile_${tile.value}'),
                            tile: tile,
                            dimension: dimension,
                            size: Size(size, size),
                          ),
                        ),
                        // ParticlePuzzleBoard(
                        //   boardSizePixels: constraints.biggest,
                        // ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ParticlePuzzleBoard extends ConsumerStatefulWidget {
  const ParticlePuzzleBoard({
    Key? key,
    required this.boardSizePixels,
  }) : super(key: key);

  final Size boardSizePixels;

  @override
  ConsumerState<ParticlePuzzleBoard> createState() =>
      _ParticlePuzzleBoardState();
}

class _ParticlePuzzleBoardState extends ConsumerState<ParticlePuzzleBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 10));

  late final ValueNotifier<double> particlePixelSize;

  // Box image data
  late Future<ui.Image> boxImage;
  late ByteData boxImageByteData;
  ui.Image? cachedBoxImage;
  // Ball image data
  late Future<ui.Image> ballImage;
  late ByteData ballImageByteData;
  ui.Image? cachedBallImage;

  late Future<List<ui.Image>> loadAllImageFuture;

  /// Load images from assets, cache them, and do initial resizing.
  void _loadImagesAndResize() async {
    final boxCompleter = Completer<ui.Image>();
    final ballCompleter = Completer<ui.Image>();
    boxImage = boxCompleter.future;
    ballImage = ballCompleter.future;

    loadAllImageFuture = Future.wait([boxImage, ballImage]);

    particlePixelSize = ValueNotifier(
      ref
          .read(Providers.box2dController)
          .box2d
          .scalarWorldToPixels(particleWorldSize),
    );

    final size = particlePixelSize.value.toInt();

    // Load and set box image
    loadImageFromAssets('assets/images/box.png').then((value) async {
      boxImageByteData = value;

      if (!kIsWeb) {
        cachedBoxImage = await resizeImage(boxImageByteData, size, size);
      } else {
        cachedBoxImage =
            await decodeImageFromList(boxImageByteData.buffer.asUint8List());
      }
      boxCompleter.complete(cachedBoxImage);
    });

    // Load and set ball image
    loadImageFromAssets('assets/images/ball.png').then((value) async {
      ballImageByteData = value;

      if (!kIsWeb) {
        cachedBallImage = await resizeImage(ballImageByteData, size, size);
      } else {
        cachedBoxImage =
            await decodeImageFromList(ballImageByteData.buffer.asUint8List());
      }

      cachedBallImage = await resizeImage(ballImageByteData, size, size);
      ballCompleter.complete(cachedBallImage);
    });
  }

  /// Resizes the loaded images based on the current simulation size.
  ///
  /// Caches the result to be readily used while resizing the images.
  void _resizeImages() {
    particlePixelSize.value = ref
        .read(Providers.box2dController)
        .box2d
        .scalarWorldToPixels(particleWorldSize);

    final size = particlePixelSize.value.toInt();

    if (!kIsWeb) {
      boxImage = resizeImage(boxImageByteData, size, size);
      boxImage.then((value) {
        cachedBoxImage = value;
      });

      ballImage = resizeImage(ballImageByteData, size, size);
      ballImage.then((value) {
        cachedBallImage = value;
      });

      loadAllImageFuture = Future.wait([boxImage, ballImage]);
    }
  }

  @override
  void initState() {
    super.initState();
    // Set the initial world size from board size
    ref
        .read(Providers.box2dController)
        .updateWorldSizeFromPixelSize(widget.boardSizePixels);

    _loadImagesAndResize();

    animationController.addListener(() {
      onAnimationUpdate();
    });
  }

  void onAnimationUpdate() {
    ref.read(Providers.box2dController.notifier).update();
  }

  @override
  void dispose() {
    animationController.removeListener(onAnimationUpdate);
    animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ParticlePuzzleBoard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update the world size on board size update
    if (oldWidget.boardSizePixels != widget.boardSizePixels) {
      ref
          .read(Providers.box2dController)
          .updateWorldSizeFromPixelSize(widget.boardSizePixels);

      _resizeImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(Providers.gameStateStatus, (prevStatus, status) {
      if (status == GameStateStatus.started) {
        animationController.repeat();
      } else if (status == GameStateStatus.finished) {
        animationController.forward(from: 0);
      } else {
        animationController.stop();
      }
    });

    return FutureBuilder<List<ui.Image>>(
      future: loadAllImageFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            if (cachedBoxImage != null && cachedBallImage != null) {
              return _drawBoard(cachedBoxImage!, cachedBallImage!);
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          default:
            if (snapshot.hasError || snapshot.data == null) {
              return const SizedBox.shrink();
            } else {
              return _drawBoard(snapshot.data![0], snapshot.data![1]);
            }
        }
      },
    );
  }

  Widget _drawBoard(ui.Image boxImage, ui.Image ballImage) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(widget.boardSizePixels),
      child: CustomPaint(
        size: Size(widget.boardSizePixels.width, widget.boardSizePixels.height),
        // foregroundPainter: Box2DPaintDebug(
        //     animation: animationController.view,
        //     box2d: ref.watch(box2DControllerProvider).box2d),
        // painter: PuzzlePaint(
        //   animation: animationController.view,
        //   box2dState: ref.watch(Providers.box2dController),
        //   boxImage: boxImage,
        //   ballImage: ballImage,
        //   particlePixelSize: particlePixelSize,
        // ),
        willChange: true,
        painter: PuzzlePaint(
          animation: animationController.view,
          box2dState: ref.watch(Providers.box2dController),
          boxImage: boxImage,
          ballImage: ballImage,
          particlePixelSize: particlePixelSize,
        ),
      ),
    );
  }
}
