import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/settings_bloc.dart';
import 'package:flutter_maps/src/support/bindable_state.dart';

class SettingsScreenBody extends StatefulWidget {
  final SettingsBloc bloc;
  SettingsScreenBody(this.bloc);

  @override
  _SettingsScreenBodyState createState() => _SettingsScreenBodyState();
}

class _SettingsScreenBodyState extends BindableState<SettingsScreenBody> {
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
