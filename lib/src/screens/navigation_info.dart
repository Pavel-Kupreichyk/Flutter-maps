enum ScreenType { main, placeAdd, placeInfo, auth, settings }

class NavigationInfo {
  static const mainRoute = '/';
  static const placeRoute = '/addEditPlaceScreen';
  static const authRoute = '/auth';
  static const settingsRoute = '/settings';
  static const placeInfo = '/placeInfo';

  final ScreenType screen;
  final Object args;

  String getRoute() {
    switch (screen) {
      case ScreenType.main:
        return mainRoute;
      case ScreenType.auth:
        return authRoute;
      case ScreenType.placeAdd:
        return placeRoute;
      case ScreenType.settings:
        return settingsRoute;
      case ScreenType.placeInfo:
        return placeInfo;
    }
    return null;
  }

  NavigationInfo(this.screen,{this.args});
}