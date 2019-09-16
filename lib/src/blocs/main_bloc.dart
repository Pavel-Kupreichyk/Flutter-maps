import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support_classes/navigation_info.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';

class MainBloc implements Disposable {
  final FirestoreService _firestoreService;
  final GeolocationService _geolocationService;

  BehaviorSubject<List<Place>> _places = BehaviorSubject();
  PublishSubject<NavigationInfo> _navigation = PublishSubject();

  MainBloc(this._firestoreService, this._geolocationService) {
    updatePlaces();
  }

  //Outputs
  Observable<List<Place>> get places => _places;
  Observable<NavigationInfo> get navigation => _navigation;

  //Input functions
  updatePlaces() async {
    var places = await _firestoreService.fetchPlaces();
    _places.sink.add(places);
  }

  addButtonPressed() {
    _navigation.sink.add(NavigationInfo('/addEditPlace'));
  }

  @override
  void dispose() {
    _places.close();
    _navigation.close();
  }
}
