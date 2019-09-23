import 'package:flutter_maps/src/screens/auth_screen.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support_classes/navigation_info.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';
import 'package:flutter_maps/src/screens/place_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainBloc implements Disposable {
  final FirestoreService _firestoreService;
  final AuthService _authService;

  BehaviorSubject<List<Place>> _places = BehaviorSubject();
  BehaviorSubject<LatLng> _location = BehaviorSubject();
  PublishSubject<NavigationInfo> _navigation = PublishSubject();

  MainBloc(this._firestoreService, this._authService) {
    refreshPlaces();
  }

  //Outputs
  Observable<List<Place>> get places => _places;
  Observable<NavigationInfo> get navigation => _navigation;
  Observable<LatLng> get location => _location;

  //Input functions
  refreshPlaces() async {
    var places = await _firestoreService.fetchPlaces();
    _places.sink.add(places);
  }

  showLocation(double lat, double lng) {
    _location.sink.add(LatLng(lat, lng));
  }

  addButtonPressed() async {
    var user = await _authService.getCurrentUser();
    if (user != null) {
      _navigation.sink.add(NavigationInfo(AddEditPlaceScreen.route));
    } else {
      _navigation.sink.add(NavigationInfo(AuthScreen.route));
    }
  }

  @override
  void dispose() {
    _places.close();
    _navigation.close();
    _location.close();
  }
}
