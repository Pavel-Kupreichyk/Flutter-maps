import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_maps/src/blocs/place_screen_bloc.dart';
import 'package:location/location.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/models/place.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

class MockGeolocationService extends Mock implements GeolocationService {}

class MockUploadManager extends Mock implements UploadManager {}

void main() {
  final MockFirestoreService firestoreService = MockFirestoreService();
  final MockGeolocationService geolocationService = MockGeolocationService();
  final MockUploadManager uploadManager = MockUploadManager();

  setUp(() {
    reset(firestoreService);
    reset(geolocationService);
    reset(uploadManager);
  });

  test('place stream emits null if place has not been added to init func', () {
    final bloc =
        AddEditPlaceBloc(firestoreService, geolocationService, uploadManager);

    expect(bloc.place, emits(null));
  });

  test('place stream emits place that has been added to init func', () {
    final testPlace = Place('test', null, 'test', 1, 1);

    final bloc = AddEditPlaceBloc(
        firestoreService, geolocationService, uploadManager, testPlace);

    expect(bloc.place, emits(testPlace));
  });

  test('addPlace calls addNewPlace with right data', () async {
    final bloc =
    AddEditPlaceBloc(firestoreService, geolocationService, uploadManager);
    LocationData location =
    LocationData.fromMap({'latitude': 23, 'longitude': 54.3});

    when(geolocationService.getCurrentLocation()).thenAnswer(
            (_) => Future.delayed(Duration(milliseconds: 50), () => location));

    bloc.addPlace('placeName', 'placeDesc');

    await untilCalled(firestoreService.addNewPlace(
        'placeName', 'placeDesc', null, 23, 54.3))
        .timeout(Duration(seconds: 3));
  });

  test(
      'error stream emits permissionNotProvided error if '
      'geolocation service throws permissionNotProvided exception', () {
    final bloc =
        AddEditPlaceBloc(firestoreService, geolocationService, uploadManager);

    when(geolocationService.getCurrentLocation())
        .thenThrow(GeoServiceException(GeoServiceError.permissionNotProvided));

    expect(bloc.error, emits(AddEditPlaceBlocError.permissionNotProvided));
    bloc.addPlace('test', 'test');
  });
}
