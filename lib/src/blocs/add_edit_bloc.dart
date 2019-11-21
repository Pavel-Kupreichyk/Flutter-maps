import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:location/location.dart';
import 'package:flutter_maps/src/support/disposable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'dart:io';

enum AddEditBlocError {
  permissionNotProvided,
  servicesDisabled,
  notLoggedIn,
  unexpectedError
}

class AddEditBloc implements Disposable {
  final FirestoreService _firestoreService;
  final GeolocationService _geolocationService;
  final UploadManager _uploadManager;
  final AuthService _authService;

  final BehaviorSubject<Place> _place;
  final BehaviorSubject<File> _image = BehaviorSubject();
  final BehaviorSubject<bool> _bottomMenuState = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _isLoading = BehaviorSubject.seeded(false);
  final PublishSubject<AddEditBlocError> _error = PublishSubject();
  final PublishSubject<String> _popWithMessage = PublishSubject();

  AddEditBloc(this._firestoreService, this._geolocationService,
      this._uploadManager, this._authService,
      [Place place])
      : _place = BehaviorSubject.seeded(place);

  //Outputs

  Observable<Place> get place => _place;
  Observable<AddEditBlocError> get error => _error;
  Observable<bool> get bottomMenuState => _bottomMenuState;
  Observable<bool> get isLoading => _isLoading;
  Observable<File> get image => _image;
  Observable<String> get popWithMessage => _popWithMessage;

  //Input functions

  Future addPlace(String name, String about) async {
    _isLoading.add(true);
    final user = await _getUserOrEmitError();
    final location = await _getLocationOrEmitError();

    if (location != null && user != null) {
      var loadingTask = await _firestoreService.addNewPlace(user, name, about,
          _image.value, location.latitude, location.longitude);
      if (loadingTask != null) {
        _uploadManager.addFirebaseUpload(loadingTask, '${name}_image');
      }
      _popWithMessage.add('Place has been successfully added.');
    }
    _isLoading.add(false);
  }

  Future requestLocationPermission() async =>
      await _geolocationService.requestGeolocationServicePermission();

  void addPhotoButtonPressed() => _bottomMenuState.add(true);

  void removeImage() => _image.add(null);

  Future addImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
    );
    if (image != null) {
      _image.add(image);
    }
  }

  Future<LocationData> _getLocationOrEmitError() async {
    try {
      return await _geolocationService.getCurrentLocation();
    } on GeoServiceException catch (error) {
      switch (error.type) {
        case GeoServiceError.permissionNotProvided:
          _error.add(AddEditBlocError.permissionNotProvided);
          break;
        case GeoServiceError.servicesDisabled:
          _error.add(AddEditBlocError.servicesDisabled);
          break;
        case GeoServiceError.unexpectedError:
          _error.add(AddEditBlocError.unexpectedError);
          break;
      }
    }
    return null;
  }

  Future<String> _getUserOrEmitError() async {
    final user = await _authService.getCurrentUser();
    if (user == null) {
      _error.add(AddEditBlocError.notLoggedIn);
    }
    return user;
  }

  @override
  void dispose() {
    _place.close();
    _error.close();
    _bottomMenuState.close();
    _image.close();
    _isLoading.close();
  }
}
