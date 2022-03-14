import 'package:flutter/material.dart';

abstract class AppColors {
  static const boardBackgroundColor = Color(0xFF2D3036);
  static const backgroundColor = Color(0xFF484B51);
  static const highlight = Color(0xFFE57751);
  static const lightBlue = Color(0xFF54C5F8);
  static const darkBlue = Color(0xFF01579B);
}

class AppTheme {
  final _darkBase = ThemeData.dark();

  ThemeData get darkTheme => _darkBase.copyWith(
        backgroundColor: AppColors.backgroundColor,
        highlightColor: AppColors.highlight,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(
              AppColors.boardBackgroundColor,
            ),
          ),
        ),
        sliderTheme: _darkBase.sliderTheme.copyWith(
          overlayColor: AppColors.darkBlue,
          thumbColor: AppColors.highlight,
          activeTrackColor: AppColors.lightBlue,
        ),
        dialogBackgroundColor: AppColors.boardBackgroundColor,
      );
}
