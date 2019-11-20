import 'package:flutter_maps/src/support/navigation_info.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_maps/src/blocs/main_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:flutter_maps/src/models/place.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  final MockFirestoreService firestoreService = MockFirestoreService();
  final MockAuthService authService = MockAuthService();

  setUp(() {
    reset(firestoreService);
    reset(authService);
  });

  test('emits list of current places after init', () {
    final listOfPlaces = [
      Place('Place1', '12345', 'Name1', null, 'Place1', 1, 1),
      Place('Place2', '9226', 'Name2', null, 'Place2', 2, 2),
      Place('Place3', '57345', 'Name3', null, 'Place3', 3, 3)
    ];

    when(firestoreService.fetchPlaces()).thenAnswer((_) =>
        Future<List<Place>>.delayed(
            Duration(milliseconds: 50), () => listOfPlaces));
    final bloc = MainBloc(firestoreService, authService);

    expect(bloc.places, emits(listOfPlaces));
  });

  test('emits list of current places after refreshPlaces called', () {
    final listOfPlaces = [
      Place('Place1', '12345', 'Name1', null, 'Place1', 1, 1),
      Place('Place2', '9226', 'Name2', null, 'Place2', 2, 2)
    ];

    final bloc = MainBloc(firestoreService, authService);
    expect(bloc.places, emitsInOrder([null, listOfPlaces]));

    when(firestoreService.fetchPlaces()).thenAnswer((_) =>
        Future<List<Place>>.delayed(
            Duration(milliseconds: 50), () => listOfPlaces));
    bloc.refreshPlaces();
  });

  test('emits NavigationInfo after addButtonPressed called', () {
    final bloc = MainBloc(firestoreService, authService);
    expect(bloc.navigate, emits(isInstanceOf<NavigationInfo>()));

    bloc.addButtonPressed();
  });
}
