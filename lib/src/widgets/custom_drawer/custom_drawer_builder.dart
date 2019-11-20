import 'package:flutter/cupertino.dart';
import 'package:flutter_maps/src/blocs/custom_drawer_bloc.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/widgets/custom_drawer/custom_drawer.dart';
import 'package:provider/provider.dart';

class CustomDrawerBuilder extends StatefulWidget {
  @override
  _CustomDrawerBuilderState createState() => _CustomDrawerBuilderState();
}

class _CustomDrawerBuilderState extends State<CustomDrawerBuilder> {
  CustomDrawerBloc _bloc;
  @override
  Widget build(BuildContext context) {
    return Consumer2<UploadManager, AuthService>(
      builder: (_, upload, auth, __) => Provider<CustomDrawerBloc>(
        builder: (_) =>
            _bloc = _bloc == null ? CustomDrawerBloc(upload, auth) : _bloc,
        dispose: (_, bloc) => bloc.dispose(),
        child: Consumer<CustomDrawerBloc>(
          builder: (_, bloc, __) => CustomDrawer(bloc),
        ),
      ),
    );
  }
}
