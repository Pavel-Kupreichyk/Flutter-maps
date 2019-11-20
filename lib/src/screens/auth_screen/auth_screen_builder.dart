import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/auth_bloc.dart';
import 'package:flutter_maps/src/screens/auth_screen/auth_screen_body.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:provider/provider.dart';

class AuthScreenBuilder extends StatefulWidget {
  @override
  _AuthScreenBuilderState createState() => _AuthScreenBuilderState();
}

class _AuthScreenBuilderState extends State<AuthScreenBuilder> {
  AuthBloc _bloc;

  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<AuthService, FirestoreService, AuthBloc>(
      builder: (_, auth, store, __) =>
      _bloc = _bloc == null ? AuthBloc(auth, store) : _bloc,
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<AuthBloc>(
        builder: (_, bloc, __) => Scaffold(
          appBar: AppBar(
            title: Text('Authentication'),
            actions: <Widget>[
              StreamBuilder<bool>(
                stream: bloc.isLoading,
                builder: (_, snapshot) {
                  if (snapshot.hasData && snapshot.data) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Center(
                          child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator())),
                    );
                  }
                  return Container();
                },
              )
            ],
          ),
          body: AuthScreenBody(bloc),
        ),
      ),
    );
  }
}