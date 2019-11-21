import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_maps/src/blocs/add_edit_bloc.dart';
import 'package:location/location.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/models/place.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

class MockGeolocationService extends Mock implements GeolocationService {}

class MockAuthService extends Mock implements AuthService {}

class MockUploadManager extends Mock implements UploadManager {}

void main() {
  final MockGeolocationService geolocationService = MockGeolocationService();
  final MockFirestoreService firestoreService = MockFirestoreService();
  final MockUploadManager uploadManager = MockUploadManager();
  final MockAuthService authService = MockAuthService();

  setUp(() {
    reset(firestoreService);
    reset(geolocationService);
    reset(uploadManager);
    reset(authService);
  });

  test('place stream emits null if place has not been added to init func', () {
    final bloc = AddEditBloc(
        firestoreService, geolocationService, uploadManager, authService);

    expect(bloc.place, emits(null));
  });

  test('place stream emits place that has been added to init func', () {
    final testPlace = Place('test', '12435', 'name1', null, 'test', 1, 1);

    final bloc = AddEditBloc(firestoreService, geolocationService,
        uploadManager, authService, testPlace);

    expect(bloc.place, emits(testPlace));
  });

  test('addPlace calls addNewPlace with right data', () async {
    final bloc = AddEditBloc(
        firestoreService, geolocationService, uploadManager, authService);
    LocationData location =
        LocationData.fromMap({'latitude': 23, 'longitude': 54.3});

    when(geolocationService.getCurrentLocation()).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50), () => location));

    when(authService.getCurrentUser()).thenAnswer((_) async => '123456');

    bloc.addPlace('placeName', 'placeDesc');

    await untilCalled(firestoreService.addNewPlace(
            '123456', 'placeName', 'placeDesc', null, 23, 54.3))
        .timeout(Duration(seconds: 3));
  });

  test(
      'error stream emits permissionNotProvided error if '
      'geolocation service throws permissionNotProvided exception', () {
    final bloc = AddEditBloc(
        firestoreService, geolocationService, uploadManager, authService);

    when(geolocationService.getCurrentLocation())
        .thenThrow(GeoServiceException(GeoServiceError.permissionNotProvided));

    when(authService.getCurrentUser()).thenAnswer((_) async => '123456');

    expect(bloc.error, emits(AddEditBlocError.permissionNotProvided));
    bloc.addPlace('test', 'test');
  });
}
