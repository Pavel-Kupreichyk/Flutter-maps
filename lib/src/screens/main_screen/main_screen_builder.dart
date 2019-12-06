import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/main_bloc.dart';
import 'package:flutter_maps/src/screens/main_screen/main_screen_body.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:flutter_maps/src/widgets/custom_drawer/custom_drawer_builder.dart';
import 'package:provider/provider.dart';

class MainScreenBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<FirestoreService, AuthService, MainBloc>(
      builder: (_, firestore, auth, prevBloc) =>
          prevBloc ?? MainBloc(firestore, auth),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<MainBloc>(
        builder: (_, bloc, __) => Scaffold(
          appBar: AppBar(
            title: Text('Map App'),
          ),
          drawer: CustomDrawerBuilder(),
          body: MainScreenBody(bloc),
          floatingActionButton: FloatingActionButton(
              child: const Icon(
                Icons.add,
              ),
              onPressed: bloc.addButtonPressed),
        ),
      ),
    );
  }
}
