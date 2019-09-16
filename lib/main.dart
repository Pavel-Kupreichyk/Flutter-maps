import 'package:flutter/material.dart';
import 'package:flutter_maps/src/screens/place_screen.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:flutter_maps/src/screens/main_screen.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_maps/src/blocs/main_bloc.dart';
import 'package:flutter_maps/src/blocs/place_screen_bloc.dart';
import 'package:flutter_maps/src/managers/alert_manager.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        Provider<GeolocationService>.value(value: GeolocationService()),
        Provider<FirestoreService>.value(value: FirestoreService()),
        Provider<AlertManager>.value(value: AlertManager()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: ProxyProvider2<FirestoreService, GeolocationService, MainBloc>(
            builder: (_, store, geo, __) => MainBloc(store, geo),
            dispose: (_, bloc) => bloc.dispose(),
            child: Consumer<MainBloc>(
              builder: (_, bloc, __) => MainScreen(bloc),
            )),
        onGenerateRoute: (RouteSettings settings) {
          Widget newScreen;
          switch (settings.name) {
            case '/addEditPlace':
              newScreen = ProxyProvider2<FirestoreService, GeolocationService,
                      AddEditPlaceBloc>(
                  builder: (_, store, geo, __) =>
                      AddEditPlaceBloc(store, geo, settings.arguments),
                  dispose: (_, bloc) => bloc.dispose(),
                  child: Consumer2<AddEditPlaceBloc, AlertManager>(
                    builder: (_, bloc, alert, __) =>
                        AddEditPlaceScreen(bloc, alert),
                  ));
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return MaterialPageRoute(
              builder: (_) => newScreen, settings: settings);
        },
      ),
    );
  }
}
//google_maps_flutter: ^0.5.21
//location: ^2.3.5
