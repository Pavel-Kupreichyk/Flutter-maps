enum ScreenType { main, place, auth }

class NavigationInfo {
  static const mainRoute = '/';
  static const placeRoute = '/addEditPlaceScreen';
  static const authRoute = '/auth';

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
    }
    return null;
  }

  NavigationInfo(this.screen,{this.args});
}