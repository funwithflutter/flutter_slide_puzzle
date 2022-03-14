import 'dart:ui';

const defaultBoardSizePixels = Size(900, 900);
const boardSizeSide = 100.0;
const particleWorldSize = 3.5;
const boardSizeWorld = Size(boardSizeSide, boardSizeSide);
const paddingRatio = 10;
const double timeStep = 1 / 60;

/// The gravity vector's y value.
const double defaultGravity = -30.0;
const double defaultBallDensity = 4;
const double defaultBallRestitution = 0.4;
const double defaultBoxDensity = 4;
const double defaultBoxRestitution = 0.2;
