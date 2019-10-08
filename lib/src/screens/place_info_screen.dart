import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/place_info_bloc.dart';
import 'package:provider/provider.dart';

class PlaceInfoScreenBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<PlaceInfoBloc>(
      builder: (_) => PlaceInfoBloc(),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<PlaceInfoBloc>(
        builder: (_, bloc, __) => Scaffold(
          body: PlaceInfoScreen(bloc),
        ),
      ),
    );
  }
}

class PlaceInfoScreen extends StatefulWidget {
  final PlaceInfoBloc bloc;
  PlaceInfoScreen(this.bloc);

  @override
  _PlaceInfoScreenState createState() => _PlaceInfoScreenState();
}

class _PlaceInfoScreenState extends State<PlaceInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          title: Text('TEST'),
          backgroundColor: Colors.green,
          expandedHeight: 200.0,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset('images/placeholder.png', fit: BoxFit.cover),
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 150.0,
          delegate: SliverChildListDelegate(
            [
              Container(color: Colors.red),
              Container(color: Colors.purple),
              Container(color: Colors.green),
              Container(color: Colors.orange),
              Container(color: Colors.yellow),
              Container(color: Colors.pink),
            ],
          ),
        ),
      ],
    );
  }
}
