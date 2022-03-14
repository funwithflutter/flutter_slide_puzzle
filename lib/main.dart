import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fun_with_flutter_slide_puzzle/app.dart';
import 'package:fun_with_flutter_slide_puzzle/theme.dart';

void main() => runApp(
      ProviderScope(
        child: App(
          appTheme: AppTheme(),
        ),
      ),
    );
