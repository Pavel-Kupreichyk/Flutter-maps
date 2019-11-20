import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/place_add_edit_bloc.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/screens/place_add_edit_screen/add_edit_screen_body.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:provider/provider.dart';

class AddEditScreenBuilder extends StatefulWidget {
  final Place _arg;

  AddEditScreenBuilder(this._arg);

  @override
  _AddEditScreenBuilderState createState() => _AddEditScreenBuilderState();
}

class _AddEditScreenBuilderState extends State<AddEditScreenBuilder> {
  AddEditPlaceBloc _bloc;
  @override
  Widget build(BuildContext context) {
    return ProxyProvider4<FirestoreService, GeolocationService, UploadManager,
        AuthService, AddEditPlaceBloc>(
      builder: (_, firestore, geo, upload, auth, __) => _bloc = _bloc == null
          ? AddEditPlaceBloc(firestore, geo, upload, auth, widget._arg)
          : _bloc,
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<AddEditPlaceBloc>(
        builder: (_, bloc, __) => Scaffold(
          appBar: AppBar(
            title: Text('Add Place'),
          ),
          body: AddEditScreenBody(bloc),
        ),
      ),
    );
  }
}