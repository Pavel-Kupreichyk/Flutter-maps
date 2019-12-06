import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/settings_bloc.dart';
import 'package:flutter_maps/src/managers/style_manager.dart';
import 'package:flutter_maps/src/screens/settings_screen/settings_screen_body.dart';
import 'package:provider/provider.dart';

class SettingsScreenBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<StyleManager, SettingsBloc>(
      builder: (_, style, prevBloc) => prevBloc ?? SettingsBloc(style),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<SettingsBloc>(
        builder: (_, bloc, __) => Scaffold(
          appBar: AppBar(title: Text('Settings')),
          body: SettingsScreenBody(bloc),
        ),
      ),
    );
  }
}
