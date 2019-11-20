import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/main_bloc.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support/alert_presenter.dart';
import 'package:flutter_maps/src/support/bindable_state.dart';
import 'package:flutter_maps/src/widgets/custom_list_tile.dart';
import 'package:flutter_maps/src/widgets/custom_layout_builder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_maps/src/widgets/custom_map.dart';

class MainScreenBody extends StatefulWidget {
  final MainBloc bloc;
  MainScreenBody(this.bloc);

  @override
  State<StatefulWidget> createState() => _MainScreenBodyState();
}

class _MainScreenBodyState extends BindableState<MainScreenBody> {
  @override
  void setupBindings() {
    bag += widget.bloc.navigate.listen((navInfo) async {
      var res = await Navigator.pushNamed(context, navInfo.getRoute(),
          arguments: navInfo.args);
      if (res != null) {
        AlertPresenter.showStandardSnackBar(context, res);
      }
    });
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
                  return CustomListTile(
                    place,
                    onLocationButtonPressed: () =>
                        bloc.showLocation(place.lat, place.lng),
                    onItemSelected: () => bloc.itemSelected(place),
                  );
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
            places: snapshot.data ?? [],
            locationUpdater: bloc.location,
          );
        });
  }
}
