import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/main_bloc.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_maps/src/widgets/custom_list_tile.dart';
import 'package:flutter_maps/src/widgets/custom_layout_builder.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static const route = '/';
  final MainBloc bloc;
  MainScreen(this.bloc);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends StateWithBag<MainScreen> {

  @override
  void setupBindings() {
    bag += widget.bloc.navigation.listen((navInfo) {
      Navigator.pushNamed(context, navInfo.route, arguments: navInfo.args);
    });
  }

  static const LatLng blr = LatLng(53.9, 27.56667);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: Stack(
        children: <Widget>[
          CustomLayoutBuilder(
            builder: (_, screenType, constraints) {
              switch (screenType) {
                case Layout.wide:
                  return Row(
                    children: _buildLayout(width: constraints.maxWidth / 2),
                  );
                case Layout.slim:
                  return Column(
                    children: _buildLayout(height: constraints.maxHeight / 2),
                  );
                default:
                  throw 'Unexpected screen type';
              }
            },
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(right: 15, bottom: 15),
              child: Align(
                alignment: FractionalOffset.bottomRight,
                child: FloatingActionButton(
                    backgroundColor: Colors.blueGrey,
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onPressed: () => widget.bloc.addButtonPressed()),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildLayout({double height, double width}) {
    return [
      Container(
        width: width,
        height: height,
        child: const GoogleMap(
          initialCameraPosition: const CameraPosition(target: blr, zoom: 9),
          myLocationButtonEnabled: false,
        ),
      ),
      const _PlacesList(),
    ];
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
                  return CustomListTile(snapshot.data[id]);
                },
              ),
            ),
          );
        });
  }
}
