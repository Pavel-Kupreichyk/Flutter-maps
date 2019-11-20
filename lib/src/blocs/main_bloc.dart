import 'package:flutter_maps/src/screens/navigation_info.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support/disposable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainBloc implements Disposable {
  final FirestoreService _firestoreService;
  final AuthService _authService;

  BehaviorSubject<List<Place>> _places = BehaviorSubject();
  BehaviorSubject<LatLng> _location = BehaviorSubject();
  PublishSubject<NavigationInfo> _navigate = PublishSubject();

  MainBloc(this._firestoreService, this._authService) {
    refreshPlaces();
  }

  //Outputs
  Observable<List<Place>> get places => _places;
  Observable<LatLng> get location => _location;
  Observable<NavigationInfo> get navigate => _navigate;

  //Input functions
  refreshPlaces() async {
    var places = await _firestoreService.fetchPlaces();
    _places.sink.add(places);
  }

  showLocation(double lat, double lng) {
    _location.sink.add(LatLng(lat, lng));
  }

  itemSelected(Place place) {
    _navigate.add(NavigationInfo(ScreenType.placeInfo, args: place));
  }

  addButtonPressed() async {
    var user = await _authService.getCurrentUser();
    if (user != null) {
      _navigate.add(NavigationInfo(ScreenType.placeAdd));
    } else {
      _navigate.add(NavigationInfo(ScreenType.auth));
    }
  }

  @override
  void dispose() {
    _places.close();
    _navigate.close();
    _location.close();
  }
}
