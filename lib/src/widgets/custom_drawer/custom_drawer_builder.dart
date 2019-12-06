import 'package:flutter/cupertino.dart';
import 'package:flutter_maps/src/blocs/custom_drawer_bloc.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/widgets/custom_drawer/custom_drawer.dart';
import 'package:provider/provider.dart';

class CustomDrawerBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<UploadManager, AuthService, CustomDrawerBloc>(
      builder: (_, upload, auth, prevBloc) =>
          prevBloc ?? CustomDrawerBloc(upload, auth),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<CustomDrawerBloc>(
        builder: (_, bloc, __) => CustomDrawer(bloc),
      ),
    );
  }
}
