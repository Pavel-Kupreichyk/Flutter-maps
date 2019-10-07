enum ScreenType { main, place, auth, settings }

class NavigationInfo {
  static const mainRoute = '/';
  static const placeRoute = '/addEditPlaceScreen';
  static const authRoute = '/auth';
  static const settingsRoute = '/settings';

  final ScreenType screen;
  final Object args;

  String getRoute() {
    switch (screen) {
      case ScreenType.main:
        return mainRoute;
      case ScreenType.auth:
        return authRoute;
      case ScreenType.place:
        return placeRoute;
      case ScreenType.settings:
        return settingsRoute;
    }
    return null;
  }

  NavigationInfo(this.screen,{this.args});
}