import 'package:flutter_maps/src/models/place.dart';

class NavigationInfo {
  static const mainRoute = '/';
  static const addEditPlaceRoute = '/addEditPlaceScreen';
  static const authRoute = '/auth';
  static const settingsRoute = '/settings';
  static const placeInfoRoute = '/placeInfo';

  final String route;
  final Object args;

  NavigationInfo.main()
      : route = mainRoute,
        args = null;

  NavigationInfo.addEdit(Place place)
      : route = addEditPlaceRoute,
        args = place;

  NavigationInfo.auth()
      : route = authRoute,
        args = null;

  NavigationInfo.settings()
      : route = settingsRoute,
        args = null;

  NavigationInfo.placeInfo(Place place)
      : route = placeInfoRoute,
        args = place;
}
