import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/managers/snack_bar_manager.dart';
import 'package:flutter_maps/src/managers/navigation_manager.dart';
import 'package:flutter_maps/src/screens/auth_screen.dart';
import 'package:flutter_maps/src/screens/place_screen.dart';
import 'package:flutter_maps/src/screens/screen_types.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:flutter_maps/src/screens/main_screen.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';
import 'package:provider/provider.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  final navKey = GlobalKey<NavigatorState>();
  final navManager = NavigationManager();
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends StateWithBag<App> {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        Provider<GeolocationService>.value(value: GeolocationService()),
        Provider<FirestoreService>.value(value: FirestoreService()),
        Provider<AuthService>.value(value: AuthService()),
        Provider<UploadManager>.value(value: UploadManager()),
        Provider<NavigationManager>.value(value: widget.navManager),
        Provider<SnackBarManager>.value(value: SnackBarManager()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        navigatorKey: widget.navKey,
        home: MainScreenBuilder(),
        onGenerateRoute: (RouteSettings settings) {
          Widget newScreen;
          switch (settings.name) {
            case PlaceScreenBuilder.route:
              newScreen = PlaceScreenBuilder(settings.arguments);
              break;
            case AuthScreenBuilder.route:
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

  @override
  void setupBindings() {
    bag += widget.navManager.navigate.listen((navInfo) {
      String routeName;
      switch (navInfo.screen) {
        case ScreenType.main:
          routeName = MainScreenBuilder.route;
          break;
        case ScreenType.auth:
          routeName = AuthScreenBuilder.route;
          break;
        case ScreenType.place:
          routeName = PlaceScreenBuilder.route;
          break;
      }
      widget.navKey.currentState.pushNamed(routeName, arguments: navInfo.args);
    });
    bag += widget.navManager.pop.listen((_) => widget.navKey.currentState.pop());
  }
}
