import 'package:flutter_maps/src/managers/style_manager.dart';
import 'package:flutter_maps/src/support/disposable.dart';
import 'package:rxdart/rxdart.dart';

class SettingsBloc implements Disposable {
  final StyleManager _styleManager;
  final BehaviorSubject<bool> _nightModeState;

  SettingsBloc(this._styleManager)
      : _nightModeState = BehaviorSubject.seeded(
            _styleManager.currentAppStyle == AppStyle.night);

  Observable<bool> get nightModeState => _nightModeState;

  void setNightMode(bool state) {
    _nightModeState.add(state);
    _styleManager.setAppStyle(state ? AppStyle.night : AppStyle.regular);
  }

  @override
  void dispose() {
    _nightModeState.close();
  }
}
