import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/place_info_bloc.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/screens/place_info_screen/place_info_screen_body.dart';
import 'package:provider/provider.dart';

class PlaceInfoScreenBuilder extends StatefulWidget {
  final Place _arg;

  PlaceInfoScreenBuilder(this._arg);

  @override
  _PlaceInfoScreenBuilderState createState() => _PlaceInfoScreenBuilderState();
}

class _PlaceInfoScreenBuilderState extends State<PlaceInfoScreenBuilder> {
  PlaceInfoBloc _bloc;
  @override
  Widget build(BuildContext context) {
    return Provider<PlaceInfoBloc>(
      builder: (_) =>
          _bloc = _bloc == null ? PlaceInfoBloc(widget._arg) : _bloc,
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<PlaceInfoBloc>(
        builder: (_, bloc, __) => Scaffold(
          body: PlaceInfoScreenBody(bloc),
        ),
      ),
    );
  }
}
