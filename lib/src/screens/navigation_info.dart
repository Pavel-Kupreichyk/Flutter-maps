enum ScreenType { main, placeAdd, placeInfo, auth, settings }

class NavigationInfo {
  static const mainRoute = '/';
  static const addEditPlaceRoute = '/addEditPlaceScreen';
  static const authRoute = '/auth';
  static const settingsRoute = '/settings';
  static const placeInfoRoute = '/placeInfo';

  final ScreenType screen;
  final Object args;

  String getRoute() {
    switch (screen) {
      case ScreenType.main:
        return mainRoute;
      case ScreenType.auth:
        return authRoute;
      case ScreenType.placeAdd:
        return addEditPlaceRoute;
      case ScreenType.settings:
        return settingsRoute;
      case ScreenType.placeInfo:
        return placeInfoRoute;
    }
    return null;
  }

  NavigationInfo(this.screen,{this.args});
}