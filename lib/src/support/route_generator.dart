import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/screens/auth_screen/auth_screen_builder.dart';
import 'package:flutter_maps/src/screens/main_screen/main_screen_builder.dart';
import 'package:flutter_maps/src/screens/navigation_info.dart';
import 'package:flutter_maps/src/screens/place_add_edit_screen/add_edit_screen_builder.dart';
import 'package:flutter_maps/src/screens/place_info_screen/place_info_screen_builder.dart';
import 'package:flutter_maps/src/screens/settings_screen/settings_screen_builder.dart';

class RouteGenerator {
  Widget get home => MainScreenBuilder();

  Route navigate(RouteSettings settings) {
    Widget newScreen;
    switch (settings.name) {
      case NavigationInfo.addEditPlaceRoute:
        newScreen = AddEditScreenBuilder(settings.arguments);
        break;
      case NavigationInfo.authRoute:
        newScreen = AuthScreenBuilder();
        break;
      case NavigationInfo.settingsRoute:
        newScreen = SettingsScreenBuilder();
        break;
      case NavigationInfo.placeInfoRoute:
        newScreen = PlaceInfoScreenBuilder(settings.arguments);
        break;
      default:
        throw Exception('Invalid route: ${settings.name}');
    }
    return MaterialPageRoute(builder: (_) => newScreen);
  }
}
