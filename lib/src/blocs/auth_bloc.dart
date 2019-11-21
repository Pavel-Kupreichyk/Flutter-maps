import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/support/disposable.dart';

enum FormMode { login, signup }

class AuthBloc implements Disposable {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  final BehaviorSubject<FormMode> _formMode =
      BehaviorSubject.seeded(FormMode.login);
  final BehaviorSubject<String> _error = BehaviorSubject();
  final BehaviorSubject<bool> _isLoading = BehaviorSubject.seeded(false);
  final PublishSubject<String> _popWithMessage = PublishSubject();

  AuthBloc(this._authService, this._firestoreService);

  //Outputs
  Observable<FormMode> get formMode => _formMode;
  Observable<String> get error => _error;
  Observable<bool> get isLoading => _isLoading;
  Observable<String> get popWithMessage => _popWithMessage;

  //Input functions
  void changeMode() {
    if (_formMode.value == FormMode.login) {
      _formMode.add(FormMode.signup);
    } else {
      _formMode.add(FormMode.login);
    }
  }

  Future submit(String email, String password, String username) async {
    _isLoading.add(true);
    try {
      if (_formMode.value == FormMode.login) {
        await _authService.signIn(email, password);
      } else {
        if (await _firestoreService.checkUsername(username)) {
          var id = await _authService.signUp(email, password);
          await _firestoreService.addNewUser(id, username);
        } else {
          _error.add('Username already exists');
          return;
        }
      }
      _popWithMessage.add('You have been logged in.');
    } catch (error) {
      _error.add(error.message);
    } finally {
      _isLoading.add(false);
    }
  }

  @override
  void dispose() {
    _isLoading.close();
    _formMode.close();
    _popWithMessage.close();
    _error.close();
  }
}
