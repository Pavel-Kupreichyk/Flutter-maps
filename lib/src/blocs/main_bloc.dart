import 'package:flutter_maps/src/managers/snack_bar_manager.dart';
import 'package:flutter_maps/src/managers/navigation_manager.dart';
import 'package:flutter_maps/src/screens/screen_types.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainBloc implements Disposable {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  final NavigationManager _navigationManager;
  final SnackBarManager _alertManager;

  BehaviorSubject<List<Place>> _places = BehaviorSubject();
  BehaviorSubject<LatLng> _location = BehaviorSubject();

  MainBloc(this._firestoreService, this._authService, this._navigationManager,
      this._alertManager) {
    refreshPlaces();
  }

  //Outputs
  Observable<List<Place>> get places => _places;
  Observable<LatLng> get location => _location;
  Observable<String> get showSnackBar => _alertManager.showSnackBar
      .where((el) => el.screenType == ScreenType.main)
      .map((el) => el.data);

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
      _navigationManager.navigateTo(ScreenType.place);
    } else {
      _navigationManager.navigateTo(ScreenType.auth);
    }
  }

  @override
  void dispose() {
    _places.close();
    _location.close();
  }
}
