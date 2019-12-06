import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/add_edit_bloc.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/screens/add_edit_screen/add_edit_screen_body.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:provider/provider.dart';

class AddEditScreenBuilder extends StatelessWidget {
  final Place _arg;

  AddEditScreenBuilder(this._arg);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider4<FirestoreService, GeolocationService, UploadManager,
        AuthService, AddEditBloc>(
      builder: (_, firestore, geo, upload, auth, prevBloc) =>
          prevBloc ?? AddEditBloc(firestore, geo, upload, auth, _arg),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<AddEditBloc>(
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
