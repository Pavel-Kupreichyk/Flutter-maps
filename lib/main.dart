import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/managers/style_manager.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:flutter_maps/src/support/route_generator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();
  final style = StyleManager(prefs);

  runApp(MultiProvider(
    providers: <SingleChildCloneableWidget>[
      Provider<GeolocationService>.value(value: GeolocationService()),
      Provider<FirestoreService>.value(value: FirestoreService()),
      Provider<AuthService>.value(value: AuthService()),
      Provider<UploadManager>.value(value: UploadManager()),
      Provider<StyleManager>.value(value: style),
    ],
    child: App(style, RouteGenerator()),
  ));
}

class App extends StatelessWidget {
  final StyleManager styleManager;
  final RouteGenerator routeGenerator;

  App(this.styleManager, this.routeGenerator);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeData>(
      stream: styleManager.appStyle,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return MaterialApp(
          theme: snapshot.data,
          home: routeGenerator.home,
          onGenerateRoute: routeGenerator.navigate,
        );
      },
    );
  }
}
