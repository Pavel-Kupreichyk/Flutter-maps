import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/custom_drawer_bloc.dart';
import 'package:flutter_maps/src/support/alert_presenter.dart';
import 'package:flutter_maps/src/models/upload_snapshot.dart';
import 'package:flutter_maps/src/support/bindable_state.dart';
import 'package:flutter_maps/src/widgets/custom_progress_bar.dart';

class CustomDrawer extends StatefulWidget {
  final CustomDrawerBloc bloc;
  CustomDrawer(this.bloc);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends BindableState<CustomDrawer> {
  @override
  void setupBindings() {
    bag += widget.bloc.userLoggedOut.listen((_) {
      AlertPresenter.showStandardSnackBar(context, 'You have been logged out.');
      Navigator.pop(context);
    });

    bag += widget.bloc.navigate.listen((navInfo) {
      Navigator.pop(context);
      Navigator.pushNamed(context, navInfo.route, arguments: navInfo.args);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text(
                'Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              leading: Icon(Icons.settings),
              onTap: widget.bloc.moveToSettings,
            ),
            StreamBuilder<bool>(
              stream: widget.bloc.isUserLoggedIn,
              builder: (_, snapshot) {
                if (snapshot.data ?? false) {
                  return ListTile(
                    title: Text(
                      'Log out',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    leading: Icon(Icons.exit_to_app),
                    onTap: widget.bloc.logOut,
                  );
                }
                return Container();
              },
            ),
            ListTile(
                title: Text(
              'Uploads',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            )),
            Expanded(
              child: StreamBuilder<List<UploadSnapshot>>(
                  stream: widget.bloc.snapshots,
                  builder: (_, snapshot) {
                    return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, id) {
                        var data = snapshot.data[id];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: CustomProgressBar(
                            data,
                            measureName: 'Kb',
                            measureDivider: 1024,
                            onRemoveButtonPressed: () =>
                                widget.bloc.removeUpload(data.name),
                          ),
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
