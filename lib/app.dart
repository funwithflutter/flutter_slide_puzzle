import 'package:flutter/material.dart';
import 'package:fun_with_flutter_slide_puzzle/screens/puzzle_page.dart';
import 'package:fun_with_flutter_slide_puzzle/theme.dart';

class App extends StatefulWidget {
  const App({
    Key? key,
    required this.appTheme,
  }) : super(key: key);

  final AppTheme appTheme;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: widget.appTheme.darkTheme,
      home: const PuzzlePage(),
    );
  }
}
