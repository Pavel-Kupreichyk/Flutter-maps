import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/settings_bloc.dart';
import 'package:flutter_maps/src/managers/style_manager.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';
import 'package:provider/provider.dart';

class SettingsScreenBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<StyleManager, SettingsBloc>(
      builder: (_, style, __) => SettingsBloc(style),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<SettingsBloc>(
        builder: (_, bloc, __) => Scaffold(
          appBar: AppBar(title: Text('Settings')),
          body: SettingsScreen(bloc),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final SettingsBloc bloc;
  SettingsScreen(this.bloc);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends StateWithBag<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        StreamBuilder<bool>(
          stream: widget.bloc.nightModeState,
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return ListTile(
              leading: Icon(Icons.brightness_3),
              title: Text('Night mode'),
              trailing: Switch(
                  value: snapshot.data, onChanged: widget.bloc.setNightMode),
            );
          },
        ),
      ],
    );
  }

  @override
  void setupBindings() {
    // TODO: implement setupBindings
  }
}
