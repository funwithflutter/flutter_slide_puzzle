import 'dart:math';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fun_with_flutter_slide_puzzle/box2d/box2d.dart';
import 'package:fun_with_flutter_slide_puzzle/layout/layout.dart';
import 'package:fun_with_flutter_slide_puzzle/state/game_state.dart';
import 'package:fun_with_flutter_slide_puzzle/state/puzzle_state.dart';
import 'package:fun_with_flutter_slide_puzzle/theme.dart';
import 'package:fun_with_flutter_slide_puzzle/widgets/puzzle_board.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/providers.dart';

class PuzzlePage extends ConsumerStatefulWidget {
  const PuzzlePage({Key? key}) : super(key: key);

  @override
  ConsumerState<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends ConsumerState<PuzzlePage> {
  final ConfettiController _confettiController = ConfettiController();

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: true,
                ),
              ),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontFamily: 'TitanOne',
                    fontSize: 32,
                  ),
                ),
              ),
            ],
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextButton(
                    onPressed: () {
                      _confettiController.stop();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontFamily: 'TitanOne',
                        fontSize: 24,
                        color: AppColors.highlight,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextButton(
                    onPressed: () {
                      ref.read(Providers.gameController.notifier).reset();
                      _confettiController.stop();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontFamily: 'TitanOne',
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PuzzleStatus>(Providers.puzzleStatus, (prev, next) {
      if (next == PuzzleStatus.complete) {
        _showPopup();
      }
    });
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              for (var i = 0; i < 20; i++) const _RandomDecoration(),
              ResponsiveLayoutBuilder(
                small: (context, child) => SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: _Title(),
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: PuzzleBoard(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Expanded(child: _StartResetButton()),
                            Expanded(child: _MakeItRainButton()),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: _GameTimeText(),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: _OptionsButton(),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: _InfoButton(),
                      )
                    ],
                  ),
                ),
                medium: (context, widget) {
                  return _horizontalLayout(rowFlex: 1, colFlex: 2);
                },
                large: (context, widget) {
                  return _horizontalLayout();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _horizontalLayout({int rowFlex = 2, int colFlex = 1}) {
    return Center(
      child: Row(
        children: [
          Expanded(
            flex: rowFlex,
            child: Container(
              color: AppColors.boardBackgroundColor,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: _MakeItRainButton(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: _GameTimeText(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: _StartResetButton(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: _OptionsButton(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: _InfoButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: colFlex,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints.loose(
                          Size.fromWidth(defaultBoardSizePixels.width),
                        ),
                        child: const _Title(),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 5,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: PuzzleBoard(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RandomDecoration extends StatefulWidget {
  const _RandomDecoration({Key? key}) : super(key: key);

  @override
  State<_RandomDecoration> createState() => _RandomDecorationState();
}

class _RandomDecorationState extends State<_RandomDecoration> {
  static const _decorations = [
    'assets/images/deco_1.png',
    'assets/images/deco_2.png',
    'assets/images/deco_3.png',
  ];

  final _random = Random();

  @override
  Widget build(BuildContext context) {
    final size = lerpDouble(10, 40, _random.nextDouble())!;
    return Align(
      alignment: Alignment(lerpDouble(-1, 1, _random.nextDouble())!,
          lerpDouble(-1, 1, _random.nextDouble())!),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(_decorations[_random.nextInt(_decorations.length)]),
      ),
    );
  }
}

class _MakeItRainButton extends ConsumerStatefulWidget {
  const _MakeItRainButton({Key? key}) : super(key: key);

  @override
  ConsumerState<_MakeItRainButton> createState() => __MakeItRainButtonState();
}

class __MakeItRainButtonState extends ConsumerState<_MakeItRainButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));

  late final scaleAnimation = Tween<double>(begin: 1, end: 1.5).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  bool makingItRain = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (makingItRain) {
        ref.read(Providers.gameController.notifier).makeItRainAndSpeedUpTimer();
      }
    });
  }

  void _startRain() {
    ref.read(Providers.gameController.notifier).addOneSecondTimePenalty();
    makingItRain = true;
    _controller.repeat(reverse: true);
  }

  void _endRain() {
    makingItRain = false;
    _controller.reverse();
    ref.read(Providers.gameController.notifier).addPenaltyToTime();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameStatus = ref.watch(Providers.gameStateStatus);
    return Opacity(
      opacity: (gameStatus == GameStateStatus.notStarted) ? 0 : 1,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) {
            _startRain();
          },
          onTap: () {
            _endRain();
          },
          onTapCancel: () {
            _endRain();
          },
          child: ScaleTransition(
            scale: scaleAnimation,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ResponsiveLayoutBuilder(
                small: (context, child) {
                  return child!;
                },
                medium: (context, child) {
                  return child!;
                },
                large: (context, child) {
                  return child!;
                },
                child: (size) {
                  late double fontSize;
                  switch (size) {
                    case ResponsiveLayoutSize.small:
                      fontSize = 32;
                      break;
                    default:
                      fontSize = 62;
                      break;
                  }
                  return Text(
                    'Rain',
                    style: TextStyle(
                      fontFamily: 'TitanOne',
                      fontSize: fontSize,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartResetButton extends ConsumerStatefulWidget {
  const _StartResetButton({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<_StartResetButton> createState() => _StartButtonState();
}

class _StartButtonState extends ConsumerState<_StartResetButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late final scaleAnimation = Tween<double>(begin: 1, end: 1.1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  void _showPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure? You will lose your progress.'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'NO',
                      style: TextStyle(
                        fontFamily: 'TitanOne',
                        fontSize: 42,
                        color: AppColors.highlight,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextButton(
                    onPressed: () {
                      ref.read(Providers.gameController.notifier).reset();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'YES',
                      style: TextStyle(
                        fontFamily: 'TitanOne',
                        fontSize: 42,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _handlePress() {
    final gameStatus = ref.read(Providers.gameStateStatus);
    if (gameStatus == GameStateStatus.notStarted) {
      ref.read(Providers.gameController.notifier).start();
      _controller.reverse();
    } else {
      _showPopup();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameStatus = ref.watch(Providers.gameStateStatus);
    var lable = 'Reset';
    bool isReset = true;
    if (gameStatus == GameStateStatus.notStarted) {
      lable = 'Start';
      isReset = false;
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        if (!isReset) {
          _controller.repeat(reverse: true);
        }
      },
      onExit: (event) {
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: _handlePress,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ResponsiveLayoutBuilder(
              small: (context, child) {
                return child!;
              },
              medium: (context, child) {
                return child!;
              },
              large: (context, child) {
                return child!;
              },
              child: (size) {
                late double fontSize;
                switch (size) {
                  case ResponsiveLayoutSize.small:
                    fontSize = 32;
                    break;
                  default:
                    fontSize = 62;
                    break;
                }
                return Text(
                  lable,
                  style: isReset
                      ? TextStyle(
                          fontFamily: 'TitanOne',
                          fontSize: fontSize,
                          color: AppColors.highlight)
                      : TextStyle(
                          fontFamily: 'TitanOne',
                          fontSize: fontSize,
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionsButton extends ConsumerStatefulWidget {
  const _OptionsButton({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<_OptionsButton> createState() => _OptionsButtonState();
}

class _OptionsButtonState extends ConsumerState<_OptionsButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late final scaleAnimation = Tween<double>(begin: 1, end: 1.1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  void _showPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Geek Tools 🤓',
                    style: TextStyle(
                      fontFamily: 'TitanOne',
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close)),
            ],
          ),
          scrollable: true,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Divider(),
              const _GravitySlider(),
              const _BallDensitySlider(),
              const _BallResitutionSlider(),
              const _BoxDensitySlider(),
              const _BoxResitutionSlider(),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton(
                  onPressed: () {
                    ref.read(Providers.configController.notifier).reset();
                  },
                  child: const Text(
                    'Reset to defaults',
                    style: TextStyle(
                      fontFamily: 'TitanOne',
                      fontSize: 22,
                      color: AppColors.highlight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(Providers.gameController.notifier).forceAWin();
                  },
                  child: const Text(
                    'Force a win',
                    style: TextStyle(
                      fontFamily: 'TitanOne',
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePress() {
    _showPopup();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        _controller.repeat(reverse: true);
      },
      onExit: (event) {
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: _handlePress,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ResponsiveLayoutBuilder(
              small: (context, child) {
                return child!;
              },
              medium: (context, child) {
                return child!;
              },
              large: (context, child) {
                return child!;
              },
              child: (size) {
                late double fontSize;
                switch (size) {
                  case ResponsiveLayoutSize.small:
                    fontSize = 18;
                    break;
                  default:
                    fontSize = 32;
                    break;
                }
                return Text(
                  'Geek 🛠',
                  style: TextStyle(
                    fontFamily: 'TitanOne',
                    fontSize: fontSize,
                    color: Colors.white70,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoButton extends ConsumerStatefulWidget {
  const _InfoButton({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<_InfoButton> createState() => _InfoButtonState();
}

class _InfoButtonState extends ConsumerState<_InfoButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late final scaleAnimation = Tween<double>(begin: 1, end: 1.1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  void _showPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Info ℹ',
                    style: TextStyle(
                      fontFamily: 'TitanOne',
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close)),
            ],
          ),
          scrollable: true,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton(
                  onPressed: () {
                    launch('https://twitter.com/gordonphayes');
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 50,
                          child: Image.asset('assets/images/twitter.png'),
                        ),
                      ),
                      const Text(
                        '@gordonphayes',
                        style: TextStyle(
                          fontFamily: 'TitanOne',
                          fontSize: 22,
                          color: AppColors.highlight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton(
                  onPressed: () {
                    launch('https://www.youtube.com/funwithflutter');
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 50,
                          child: Image.asset('assets/images/youtube.png'),
                        ),
                      ),
                      const Text(
                        'Fun With Flutter',
                        style: TextStyle(
                          fontFamily: 'TitanOne',
                          fontSize: 22,
                          color: AppColors.highlight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton(
                  onPressed: () {
                    launch('https://github.com/HayesGordon');
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 50,
                          child: Image.asset('assets/images/github.png'),
                        ),
                      ),
                      const Text(
                        'Gordon Hayes',
                        style: TextStyle(
                          fontFamily: 'TitanOne',
                          fontSize: 22,
                          color: AppColors.highlight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton(
                  onPressed: () {
                    launch('https://github.com/funwithflutter');
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 50,
                          child: Image.asset('assets/images/github.png'),
                        ),
                      ),
                      const Text(
                        'Fun With Flutter',
                        style: TextStyle(
                          fontFamily: 'TitanOne',
                          fontSize: 22,
                          color: AppColors.highlight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton(
                  onPressed: () {
                    launch(
                        'https://dribbble.com/shots/12995366-Black-Sphere-Create-3D-object-in-Figma');
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 50,
                          child: Image.asset('assets/images/dribble.png'),
                        ),
                      ),
                      const Text(
                        'Design Inspiration',
                        style: TextStyle(
                          fontFamily: 'TitanOne',
                          fontSize: 22,
                          color: AppColors.highlight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePress() {
    _showPopup();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        _controller.repeat(reverse: true);
      },
      onExit: (event) {
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: _handlePress,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ResponsiveLayoutBuilder(
              small: (context, child) {
                return child!;
              },
              medium: (context, child) {
                return child!;
              },
              large: (context, child) {
                return child!;
              },
              child: (size) {
                late double fontSize;
                switch (size) {
                  case ResponsiveLayoutSize.small:
                    fontSize = 18;
                    break;
                  default:
                    fontSize = 32;
                    break;
                }
                return Text(
                  'Info ℹ',
                  style: TextStyle(
                    fontFamily: 'TitanOne',
                    fontSize: fontSize,
                    color: Colors.white70,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

final _gravityProvider = Provider<double>((ref) {
  return ref.watch(Providers.configController).gravity;
});

class _GravitySlider extends ConsumerWidget {
  const _GravitySlider({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _gravity = ref.watch(_gravityProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: 'The world gravity',
          child: Text(
            'Gravity:    ${_gravity.round()}',
            style: const TextStyle(fontFamily: 'TitanOne', fontSize: 20),
          ),
        ),
        Slider(
          value: _gravity,
          max: 200,
          min: -200,
          divisions: 200,
          label: _gravity.round().toString(),
          onChanged: (double value) {
            ref.read(Providers.configController.notifier).updateGravity(value);
          },
        ),
      ],
    );
  }
}

final _ballDensityProvider = Provider<double>((ref) {
  return ref.watch(Providers.configController).ballDensity;
});

class _BallDensitySlider extends ConsumerWidget {
  const _BallDensitySlider({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _ballDensity = ref.watch(_ballDensityProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: 'The balls density, usually in kg/m^2',
          child: Text(
            'Ball Density:    ${_ballDensity.round()}',
            style: const TextStyle(fontFamily: 'TitanOne', fontSize: 20),
          ),
        ),
        Slider(
          value: _ballDensity,
          max: 100,
          min: 1,
          divisions: 99,
          label: _ballDensity.round().toString(),
          onChanged: (double value) {
            ref
                .read(Providers.configController.notifier)
                .updateBallDensity(value);
          },
        ),
      ],
    );
  }
}

final _ballRestitutionProvider = Provider<double>((ref) {
  return ref.watch(Providers.configController).ballRestitution;
});

class _BallResitutionSlider extends ConsumerWidget {
  const _BallResitutionSlider({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _ballRestitution = ref.watch(_ballRestitutionProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: 'The balls restitution (elasticity)',
          child: Text(
            'Ball Restitution:    $_ballRestitution',
            style: const TextStyle(fontFamily: 'TitanOne', fontSize: 20),
          ),
        ),
        Slider(
          value: _ballRestitution,
          max: 1,
          min: 0,
          divisions: 100,
          label: _ballRestitution.round().toString(),
          onChanged: (double value) {
            ref
                .read(Providers.configController.notifier)
                .updateBallRestitution(value);
          },
        ),
      ],
    );
  }
}

final _boxDensityProvider = Provider<double>((ref) {
  return ref.watch(Providers.configController).boxDensity;
});

class _BoxDensitySlider extends ConsumerWidget {
  const _BoxDensitySlider({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _boxDensity = ref.watch(_boxDensityProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: 'The boxes density, usually in kg/m^2',
          child: Text(
            'Box Density:    ${_boxDensity.round()}',
            style: const TextStyle(fontFamily: 'TitanOne', fontSize: 20),
          ),
        ),
        Slider(
          value: _boxDensity,
          max: 100,
          min: 1,
          divisions: 99,
          label: _boxDensity.round().toString(),
          onChanged: (double value) {
            ref
                .read(Providers.configController.notifier)
                .updateBoxDensity(value);
          },
        ),
      ],
    );
  }
}

final _boxRestitutionProvider = Provider<double>((ref) {
  return ref.watch(Providers.configController).boxRestitution;
});

class _BoxResitutionSlider extends ConsumerWidget {
  const _BoxResitutionSlider({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _boxResitution = ref.watch(_boxRestitutionProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: 'The boxes restitution (elasticity)',
          child: Text(
            'Box Restitution:    $_boxResitution',
            style: const TextStyle(fontFamily: 'TitanOne', fontSize: 20),
          ),
        ),
        Slider(
          value: _boxResitution,
          max: 1,
          min: 0,
          divisions: 100,
          label: _boxResitution.round().toString(),
          onChanged: (double value) {
            ref
                .read(Providers.configController.notifier)
                .updateBoxRestitution(value);
          },
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/title.png',
      fit: BoxFit.contain,
    );
  }
}

final _gameTimeProvider = Provider<int>((ref) {
  final state = ref.watch(Providers.gameController);
  return state.gameTime + state.totalTimePenalty;
});

final _currentTimePenaltyProvider = Provider<int>((ref) {
  return ref.watch(Providers.gameController).currentTimePenalty.inSeconds;
});

class _GameTimeText extends ConsumerWidget {
  const _GameTimeText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = ref.watch(_gameTimeProvider);
    final currentTimePenalty = ref.watch(_currentTimePenaltyProvider);
    final gameStatus = ref.watch(Providers.gameStateStatus);
    return Opacity(
      opacity: (gameStatus == GameStateStatus.notStarted) ? 0 : 1,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: FittedBox(
              key: key,
              fit: BoxFit.scaleDown,
              child: ResponsiveLayoutBuilder(
                small: (context, child) {
                  return child!;
                },
                medium: (context, child) {
                  return child!;
                },
                large: (context, child) {
                  return child!;
                },
                child: (size) {
                  late double fontSize;
                  switch (size) {
                    case ResponsiveLayoutSize.small:
                      fontSize = 42;
                      break;
                    default:
                      fontSize = 112;
                      break;
                  }
                  return Text(
                    '$time',
                    style:
                        TextStyle(fontFamily: 'TitanOne', fontSize: fontSize),
                  );
                },
              ),
            ),
          ),
          Visibility(
            visible: currentTimePenalty != 0,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ResponsiveLayoutBuilder(
                    small: (context, child) {
                      return child!;
                    },
                    medium: (context, child) {
                      return child!;
                    },
                    large: (context, child) {
                      return child!;
                    },
                    child: (size) {
                      late double fontSize;
                      switch (size) {
                        case ResponsiveLayoutSize.small:
                          fontSize = 32;
                          break;
                        default:
                          fontSize = 100;
                          break;
                      }
                      return Text(
                        '+$currentTimePenalty',
                        style: TextStyle(
                          fontFamily: 'TitanOne',
                          fontSize: fontSize,
                          shadows: const <Shadow>[
                            Shadow(
                              offset: Offset(3.0, 3.0),
                              blurRadius: 10.0,
                              color: Colors.black45,
                            ),
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 8.0,
                              color: Colors.black87,
                            ),
                          ],
                          color: AppColors.highlight,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
