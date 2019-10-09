import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/managers/style_manager.dart';
import 'package:flutter_maps/src/screens/auth_screen.dart';
import 'package:flutter_maps/src/screens/place_add_edit_screen.dart';
import 'package:flutter_maps/src/screens/navigation_info.dart';
import 'package:flutter_maps/src/screens/place_info_screen.dart';
import 'package:flutter_maps/src/screens/settings_screen.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:flutter_maps/src/screens/main_screen.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();
  runApp(App(prefs));
}

class App extends StatelessWidget {
  final StyleManager _styleManager;

  App(SharedPreferences prefs) : _styleManager = StyleManager(prefs);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        Provider<GeolocationService>.value(value: GeolocationService()),
        Provider<FirestoreService>.value(value: FirestoreService()),
        Provider<AuthService>.value(value: AuthService()),
        Provider<UploadManager>.value(value: UploadManager()),
        Provider<StyleManager>.value(value: _styleManager),
      ],
      child: StreamBuilder<ThemeData>(
        stream: _styleManager.appStyle,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return MaterialApp(
            theme: snapshot.data,
            home: MainScreenBuilder(),
            onGenerateRoute: _navigate,
          );
        },
      ),
    );
  }

  MaterialPageRoute _navigate(RouteSettings settings) {
    Widget newScreen;
    switch (settings.name) {
      case NavigationInfo.placeRoute:
        newScreen = PlaceScreenBuilder(settings.arguments);
        break;
      case NavigationInfo.authRoute:
        newScreen = AuthScreenBuilder();
        break;
      case NavigationInfo.settingsRoute:
        newScreen = SettingsScreenBuilder();
        break;
      case NavigationInfo.placeInfo:
        newScreen = PlaceInfoScreenBuilder(settings.arguments);
        break;
      default:
        throw Exception('Invalid route: ${settings.name}');
    }
    return MaterialPageRoute(builder: (_) => newScreen);
  }
}
