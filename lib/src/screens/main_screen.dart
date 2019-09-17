import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/main_bloc.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_maps/src/widgets/custom_list_tile.dart';

class MainScreen extends StatefulWidget {
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
          StreamBuilder<List<Place>>(
            stream: widget.bloc.places,
            builder: (_, snapshot) {
              return Column(
                children: <Widget>[
                  Container(
                    height: 350,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: blr, zoom: 9),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (_, id) {
                          return CustomListTile(snapshot.data[id]);
                        }),
                  )
                ],
              );
            },
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(right: 15,bottom: 15),
              child: Align(
                alignment: FractionalOffset.bottomRight,
                child: FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => widget.bloc.addButtonPressed()),
              ),
            ),
          )
        ],
      ),
    );
  }
}
