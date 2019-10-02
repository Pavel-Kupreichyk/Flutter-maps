import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/screens/auth_screen.dart';
import 'package:flutter_maps/src/screens/place_screen.dart';
import 'package:flutter_maps/src/screens/navigation_info.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:flutter_maps/src/screens/main_screen.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        Provider<GeolocationService>.value(value: GeolocationService()),
        Provider<FirestoreService>.value(value: FirestoreService()),
        Provider<AuthService>.value(value: AuthService()),
        Provider<UploadManager>.value(value: UploadManager()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: MainScreenBuilder(),
        onGenerateRoute: (RouteSettings settings) {
          Widget newScreen;
          switch (settings.name) {
            case NavigationInfo.placeRoute:
              newScreen = PlaceScreenBuilder(settings.arguments);
              break;
            case NavigationInfo.authRoute:
              newScreen = AuthScreenBuilder();
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return MaterialPageRoute(builder: (_) => newScreen);
        },
      ),
    );
  }
}
