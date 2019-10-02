import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/main_bloc.dart';
import 'package:flutter_maps/src/managers/snack_bar_manager.dart';
import 'package:flutter_maps/src/managers/navigation_manager.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:flutter_maps/src/support_classes/alert_presenter.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';
import 'package:flutter_maps/src/widgets/custom_list_tile.dart';
import 'package:flutter_maps/src/widgets/custom_layout_builder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_maps/src/widgets/custom_map.dart';
import 'package:flutter_maps/src/widgets/custom_drawer.dart';

class MainScreenBuilder extends StatelessWidget {
  static const route = '/';

  @override
  Widget build(BuildContext context) {
    return ProxyProvider4<FirestoreService, AuthService, NavigationManager,
        SnackBarManager, MainBloc>(
      builder: (_, firestore, auth, nav, alert, __) =>
          MainBloc(firestore, auth, nav, alert),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<MainBloc>(
        builder: (_, bloc, __) => Scaffold(
          appBar: AppBar(
            title: Text('Map App'),
          ),
          drawer: CustomDrawerBuilder(),
          body: MainScreen(bloc),
          floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blueGrey,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () => bloc.addButtonPressed()),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final MainBloc bloc;
  MainScreen(this.bloc);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends StateWithBag<MainScreen> {

  @override
  void setupBindings() {
    bag += widget.bloc.showSnackBar.listen((data) =>
      AlertPresenter.showStandardSnackBar(context, data));
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayoutBuilder(
      builder: (_, screenType, constraints) {
        switch (screenType) {
          case Layout.wide:
            return Row(
              children: <Widget>[
                Container(width: constraints.maxWidth / 2, child: const _Map()),
                const _PlacesList()
              ],
            );
          case Layout.slim:
            return Column(
              children: <Widget>[
                Container(
                    height: constraints.maxHeight / 2, child: const _Map()),
                const _PlacesList()
              ],
            );
          default:
            throw 'Unexpected screen type';
        }
      },
    );
  }
}

class _PlacesList extends StatelessWidget {
  const _PlacesList();

  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<MainBloc>(context);
    return StreamBuilder<List<Place>>(
        stream: bloc.places,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Expanded(
                child: Center(
              child: CircularProgressIndicator(),
            ));
          }
          return Expanded(
            child: RefreshIndicator(
              onRefresh: () => bloc.refreshPlaces(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (_, id) {
                  var place = snapshot.data[id];
                  return CustomListTile(place,
                      onItemSelected: () =>
                          bloc.showLocation(place.lat, place.lng));
                },
              ),
            ),
          );
        });
  }
}

class _Map extends StatelessWidget {
  const _Map();

  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<MainBloc>(context);
    return StreamBuilder<List<Place>>(
        stream: bloc.places,
        builder: (_, snapshot) {
          return CustomMap(
            bloc,
            places: snapshot.data ?? [],
          );
        });
  }
}
