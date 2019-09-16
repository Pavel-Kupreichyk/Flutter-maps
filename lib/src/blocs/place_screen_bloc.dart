import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:location/location.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support_classes/navigation_info.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

enum AddEditPlaceBlocError {
  permissionNotProvided,
  servicesDisabled,
  unexpectedError
}

class AddEditPlaceBloc implements Disposable {
  final FirestoreService _firestoreService;
  final GeolocationService _geolocationService;

  BehaviorSubject<Place> _place;
  BehaviorSubject<File> _image = BehaviorSubject();
  BehaviorSubject<bool> _bottomMenuState = BehaviorSubject.seeded(false);
  PublishSubject<NavigationInfo> _navigation = PublishSubject();
  PublishSubject<AddEditPlaceBlocError> _error = PublishSubject();

  AddEditPlaceBloc(this._firestoreService, this._geolocationService,
      [Place place]) {
    _place = BehaviorSubject.seeded(place);
  }

  //Outputs

  Observable<Place> get place => _place;
  Observable<NavigationInfo> get navigation => _navigation;
  Observable<AddEditPlaceBlocError> get error => _error;
  Observable<bool> get bottomMenuState => _bottomMenuState;
  Observable<File> get image => _image;

  //Input functions

  updatePlaces(String name, String about) async {
    if (!await _geolocationService.hasGeolocationServicePermission()) {
      _error.sink.add(AddEditPlaceBlocError.permissionNotProvided);
      return;
    }

    LocationData location = await _getLocationOrEmitError();
    if (location != null) {
      await _firestoreService.addNewPlace(
          name, about, _image.value, location.latitude, location.longitude);
    }
  }

  requestLocationPermission() async {
    await _geolocationService.requestGeolocationServicePermission();
  }

  addPhotoButtonPressed() async {
    _bottomMenuState.add(true);
  }

  addImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      _image.add(image);
    }
  }

  //Private functions

  Future<LocationData> _getLocationOrEmitError() async {
    try {
      return await _geolocationService.getCurrentLocation();
    } on GeoServiceException catch (error) {
      switch (error.type) {
        case GeoServiceError.permissionNotProvided:
          _error.sink.add(AddEditPlaceBlocError.permissionNotProvided);
          break;
        case GeoServiceError.servicesDisabled:
          _error.sink.add(AddEditPlaceBlocError.servicesDisabled);
          break;
        case GeoServiceError.unexpectedError:
          _error.sink.add(AddEditPlaceBlocError.unexpectedError);
          break;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _place.close();
    _navigation.close();
    _error.close();
    _bottomMenuState.close();
    _image.close();
  }
}
