import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const orange = Color(0xFFFF7A00);
const orangeDark = Color(0xFFE86200);
const navy = Color(0xFF0B1730);
const bg = Color(0xFFFFF8F1);
const green = Color(0xFF18A875);

final helpiTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: bg,
  colorScheme: ColorScheme.fromSeed(seedColor: orange, brightness: Brightness.light),
  fontFamily: 'Arial',
  visualDensity: VisualDensity.adaptivePlatformDensity,
  splashFactory: InkSparkle.splashFactory,
  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
  }),
  appBarTheme: const AppBarTheme(
    backgroundColor: orange,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: const CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(color: orange, width: 1.5)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: orange,
      foregroundColor: Colors.white,
      minimumSize: const Size(44, 48),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(44, 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: const BorderSide(color: Color(0xFFE7D8CB)),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  ),
  scrollbarTheme: ScrollbarThemeData(
    thumbVisibility: WidgetStateProperty.all(false),
    radius: const Radius.circular(12),
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 72,
    backgroundColor: Colors.white,
    indicatorColor: orange.withValues(alpha: .14),
    labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
      fontSize: 11,
      fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
      color: states.contains(WidgetState.selected) ? navy : Colors.black54,
    )),
  ),
);

final helpiDarkTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: ColorScheme.fromSeed(seedColor: orange, brightness: Brightness.dark),
  fontFamily: 'Arial',
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: const CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: Color(0xFF1E1E1E),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF2C2C2C),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(color: orange, width: 1.5)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: orange,
      foregroundColor: Colors.white,
      minimumSize: const Size(44, 48),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 72,
    backgroundColor: const Color(0xFF1E1E1E),
    indicatorColor: orange.withValues(alpha: .2),
    labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
      fontSize: 11,
      fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
      color: states.contains(WidgetState.selected) ? orange : Colors.white70,
    )),
  ),
);
