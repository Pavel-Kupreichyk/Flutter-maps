import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/multi_page_navigation_bar_bloc.dart';
import 'package:flutter_maps/src/managers/alert_presenter.dart';
import 'package:flutter_maps/src/managers/route_manager.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/models/upload_snapshot.dart';
import 'package:flutter_maps/src/screens/main_screen.dart';
import 'package:flutter_maps/src/screens/place_screen.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';
import 'package:flutter_maps/src/widgets/custom_progress_bar.dart';
import 'package:provider/provider.dart';

class AppBarBuilder extends StatefulWidget {
  final Widget child;
  AppBarBuilder({this.child});

  @override
  State<StatefulWidget> createState() => AppBarBuilderState();
}

class AppBarBuilderState extends State<AppBarBuilder> {
  Widget _widget;

  @override
  void initState() {
    _widget = Consumer2<UploadManager, AuthService>(
      builder: (_, upload, auth, __) => Provider<MultiPageNavBarBloc>(
        builder: (_) => MultiPageNavBarBloc(upload, auth),
        dispose: (_, bloc) => bloc.dispose(),
        child: Consumer2<MultiPageNavBarBloc, RouteManager>(
          builder: (_, bloc, route, __) =>
              MultiPageNavBar(bloc, route, child: widget.child),
        ),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _widget;
  }
}

class MultiPageNavBar extends StatelessWidget {
  final Widget child;
  final RouteManager routeManager;
  final MultiPageNavBarBloc bloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  MultiPageNavBar(this.bloc, this.routeManager, {this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: StreamBuilder<Route>(
          stream: routeManager.route,
          builder: (_, snapshot) {
            bool isFirstPage = snapshot.data?.isFirst ?? true;
            return isFirstPage ? _buildDrawerButton() : _buildBackButton();
          },
        ),
        title: StreamBuilder<Route>(
          stream: routeManager.route,
          builder: (_, snapshot) {
            return Text(_createTitle(snapshot.data));
          },
        ),
      ),
      drawer: Consumer<AlertPresenter>(
        builder: (_, alert, __) => _CustomDrawer(bloc, alert),
      ),
      body: child,
    );
  }

  Widget _buildDrawerButton() {
    return IconButton(
      icon: const Icon(Icons.list),
      onPressed: () => _scaffoldKey.currentState.openDrawer(),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => routeManager.navigator.pop(),
    );
  }

  String _createTitle(Route route) {
    switch (route?.settings?.name) {
      case AddEditPlaceScreen.route:
        return 'Add New Place';
      case MainScreen.route:
        return 'Map App';
      default:
        return '';
    }
  }
}

class _CustomDrawer extends StatefulWidget {
  final MultiPageNavBarBloc bloc;
  final AlertPresenter alertPresenter;

  _CustomDrawer(this.bloc, this.alertPresenter);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends StateWithBag<_CustomDrawer> {
  @override
  void setupBindings() {
    bag += widget.bloc.userLoggedOut.listen((_) {
      widget.alertPresenter.showStandardSnackBar(context, 'You logged out');
      // Find a way to pop drawer
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder<bool>(
                stream: widget.bloc.isUserLoggedIn,
                builder: (_, snapshot) {
                  if (snapshot.data == true) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      //Use list tile
                      child: InkResponse(
                        child: Text(
                          'Log out',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        onTap: () => widget.bloc.logOut(),
                      ),
                    );
                  }
                  return Container();
                },
              ),
              Text(
                'Uploads',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Expanded(
                child: StreamBuilder<List<UploadSnapshot>>(
                    stream: widget.bloc.snapshots,
                    builder: (_, snapshot) {
                      return ListView.builder(
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (context, id) {
                          var data = snapshot.data[id];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
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
      ),
    );
  }
}
