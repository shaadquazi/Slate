import 'package:flutter/material.dart';

ThemeData get primaryTheme {
  const surface = Color(0xFFFAFAFA);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blueGrey,
    brightness: Brightness.light,
    surface: surface,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'AppFont',
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: surface,
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
  );
}

ThemeData get secondaryTheme {
  const surface = Color(0xFF121212);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blueGrey,
    brightness: Brightness.dark,
    surface: surface,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'AppFont',
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: surface,
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
  );
}
