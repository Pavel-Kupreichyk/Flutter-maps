import 'package:flutter_maps/src/screens/screen_types.dart';
import 'package:rxdart/rxdart.dart';

class NavigationManager {
  PublishSubject<NavigationInfo> _navigateTo = PublishSubject();
  PublishSubject<void> _popCurrent = PublishSubject();

  Observable<NavigationInfo> get navigate =>  _navigateTo;
  Observable<void> get pop => _popCurrent;

  navigateTo(ScreenType screen, {Object args}) =>
      _navigateTo.add(NavigationInfo(screen, args));
  popCurrent() => _popCurrent.add(null);
}

class NavigationInfo {
  final ScreenType screen;
  final Object args;
  NavigationInfo(this.screen, this.args);
}
