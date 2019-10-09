import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class PlaceInfoBloc implements Disposable {
  final Place _place;
  PlaceInfoBloc(this._place);

  LatLng get placeLocation => LatLng(_place.lat, _place.lng);
  Place get place => _place;

  @override
  void dispose() {}
}
