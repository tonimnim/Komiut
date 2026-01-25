import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeEvent {}
class ToggleTheme extends ThemeEvent {
  final bool isDark;
  ToggleTheme(this.isDark);
}
class LoadTheme extends ThemeEvent {}

class ThemeState {
  final ThemeMode themeMode;
  ThemeState(this.themeMode);
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences prefs;

  ThemeBloc(this.prefs) : super(ThemeState(_getInitialTheme(prefs))) {
    on<ToggleTheme>((event, emit) async {
      await prefs.setBool('isDarkMode', event.isDark);
      emit(ThemeState(event.isDark ? ThemeMode.dark : ThemeMode.light));
    });

    on<LoadTheme>((event, emit) {
      emit(ThemeState(_getInitialTheme(prefs)));
    });
  }

  static ThemeMode _getInitialTheme(SharedPreferences prefs) {
    final isDark = prefs.getBool('isDarkMode');
    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
