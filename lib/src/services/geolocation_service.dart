import 'package:location/location.dart';

enum GeoServiceError {
  permissionNotProvided,
  servicesDisabled,
  unexpectedError
}

class GeoServiceException implements Exception {
  final GeoServiceError type;
  GeoServiceException(this.type);
}

class GeolocationService {
  final _location = Location();

  Future<bool> hasGeolocationServicePermission() async {
    return await _location.hasPermission();
  }

  Future<bool> isGeolocationServiceEnabled() async {
    return await _location.serviceEnabled();
  }

  Future<bool> requestGeolocationServicePermission() async {
    return await _location.requestPermission();
  }

  Future<LocationData> getCurrentLocation() async {
    if (!await _location.hasPermission()) {
      throw GeoServiceException(GeoServiceError.permissionNotProvided);
    }

    if (!await _location.serviceEnabled()) {
      throw GeoServiceException(GeoServiceError.servicesDisabled);
    }

    try {
      return await _location.getLocation();
    } catch (error) {
      print(error);
      throw GeoServiceException(GeoServiceError.unexpectedError);
    }
  }
}
