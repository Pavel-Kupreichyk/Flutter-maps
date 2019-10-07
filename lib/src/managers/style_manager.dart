import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppStyle { night, regular }

class StyleManager {
  final SharedPreferences _sharedPreferences;
  final AppStyle _defaultTheme = AppStyle.night;
  BehaviorSubject<AppStyle> _appStyle;

  Observable<ThemeData> get appStyle => _appStyle.map(_getTheme);

  AppStyle get currentAppStyle => AppStyle
      .values[_sharedPreferences.getInt('app_style') ?? _defaultTheme.index];

  StyleManager(this._sharedPreferences) {
    _appStyle = BehaviorSubject.seeded(currentAppStyle);
  }

  setAppStyle(AppStyle style) {
    _sharedPreferences.setInt('app_style', style.index);
    _appStyle.add(style);
  }

  ThemeData _getTheme(AppStyle style) {
    switch (style) {
      case AppStyle.regular:
        return ThemeData.light();
      case AppStyle.night:
        return ThemeData.dark();
    }
    throw 'Unexpected style';
  }
}
