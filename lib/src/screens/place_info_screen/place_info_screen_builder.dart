import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/place_info_bloc.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/screens/place_info_screen/place_info_screen_body.dart';
import 'package:provider/provider.dart';

class PlaceInfoScreenBuilder extends StatelessWidget {
  final Place _arg;

  PlaceInfoScreenBuilder(this._arg);

  @override
  Widget build(BuildContext context) {
    return Provider<PlaceInfoBloc>(
      builder: (_) => PlaceInfoBloc(_arg),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<PlaceInfoBloc>(
        builder: (_, bloc, __) => Scaffold(
          body: PlaceInfoScreenBody(bloc),
        ),
      ),
    );
  }
}
