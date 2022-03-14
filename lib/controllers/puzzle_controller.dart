import 'dart:math';

import 'package:riverpod/riverpod.dart';
import 'package:fun_with_flutter_slide_puzzle/state/puzzle_state.dart';
import 'package:fun_with_flutter_slide_puzzle/models/models.dart';

final puzzleControllerProvider =
    StateNotifierProvider<PuzzleController, PuzzleState>(
  (ref) => PuzzleController(puzzelSize: 4)..initializePuzzle(shuffle: false),
);

class PuzzleController extends StateNotifier<PuzzleState> {
  PuzzleController({required int puzzelSize, this.random})
      : _size = puzzelSize,
        super(const PuzzleState(puzzle: Puzzle(tiles: [])));

  final int _size;
  final Random? random;

  /// Build a randomized, solvable puzzle of the given size.
  Puzzle _generatePuzzle(int size, {bool shuffle = true}) {
    final correctPositions = <Position>[];
    final currentPositions = <Position>[];
    final whitespacePosition = Position(x: size, y: size);

    // Create all possible board positions.
    for (var y = 1; y <= size; y++) {
      for (var x = 1; x <= size; x++) {
        if (x == size && y == size) {
          correctPositions.add(whitespacePosition);
          currentPositions.add(whitespacePosition);
        } else {
          final position = Position(x: x, y: y);
          correctPositions.add(position);
          currentPositions.add(position);
        }
      }
    }

    if (shuffle) {
      // Randomize only the current tile posistions.
      currentPositions.shuffle(random);
    }

    var tiles = _getTileListFromPositions(
      size,
      correctPositions,
      currentPositions,
    );

    var puzzle = Puzzle(tiles: tiles);

    if (shuffle) {
      // Assign the tiles new current positions until the puzzle is solvable and
      // zero tiles are in their correct position.
      while (!puzzle.isSolvable() || puzzle.getNumberOfCorrectTiles() != 0) {
        currentPositions.shuffle(random);
        tiles = _getTileListFromPositions(
          size,
          correctPositions,
          currentPositions,
        );
        puzzle = Puzzle(tiles: tiles);
      }
    }

    return puzzle;
  }

  /// Build a list of tiles - giving each tile their correct position and a
  /// current position.
  List<Tile> _getTileListFromPositions(
    int size,
    List<Position> correctPositions,
    List<Position> currentPositions,
  ) {
    final whitespacePosition = Position(x: size, y: size);
    return [
      for (int i = 1; i <= size * size; i++)
        if (i == size * size)
          Tile(
            value: i,
            correctPosition: whitespacePosition,
            currentPosition: currentPositions[i - 1],
            isWhitespace: true,
          )
        else
          Tile(
            value: i,
            correctPosition: correctPositions[i - 1],
            currentPosition: currentPositions[i - 1],
          )
    ];
  }

  void initializePuzzle({bool shuffle = true}) {
    final puzzle = _generatePuzzle(_size, shuffle: shuffle);
    state = PuzzleState(
      puzzle: puzzle.sort(),
      numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
    );
  }

  void forceComplete() {
    final puzzle = _generatePuzzle(_size, shuffle: false);
    state = state.copyWith(
      puzzle: puzzle,
      puzzleStatus: PuzzleStatus.complete,
    );
  }

  void tapTile(Tile tappedTile) {
    if (state.puzzleStatus == PuzzleStatus.incomplete) {
      if (state.puzzle.isTileMovable(tappedTile)) {
        final mutablePuzzle = Puzzle(tiles: [...state.puzzle.tiles]);
        final puzzle = mutablePuzzle.moveTiles(tappedTile, []);
        if (puzzle.isComplete()) {
          state = state.copyWith(
            puzzle: puzzle.sort(),
            puzzleStatus: PuzzleStatus.complete,
            tileMovementStatus: TileMovementStatus.moved,
            numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
            numberOfMoves: state.numberOfMoves + 1,
            lastTappedTile: tappedTile,
          );
        } else {
          state = state.copyWith(
            puzzle: puzzle.sort(),
            tileMovementStatus: TileMovementStatus.moved,
            numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
            numberOfMoves: state.numberOfMoves + 1,
            lastTappedTile: tappedTile,
          );
        }
      } else {
        state = state.copyWith(
            tileMovementStatus: TileMovementStatus.cannotBeMoved);
      }
    } else {
      state =
          state.copyWith(tileMovementStatus: TileMovementStatus.cannotBeMoved);
    }
  }

  void resetPuzzle() {
    final puzzle = _generatePuzzle(_size);
    state = PuzzleState(
      puzzle: puzzle.sort(),
      numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
    );
  }
}
