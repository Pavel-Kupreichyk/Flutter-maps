import 'dart:io';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';

enum FormMode { login, signup }

class AuthBloc implements Disposable {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  BehaviorSubject<FormMode> _formMode = BehaviorSubject.seeded(FormMode.login);
  BehaviorSubject<String> _error = BehaviorSubject();
  BehaviorSubject<bool> _isLoading = BehaviorSubject.seeded(false);
  PublishSubject<String> _popWithMessage = PublishSubject();

  AuthBloc(this._authService, this._firestoreService);

  //Outputs
  Observable<FormMode> get formMode => _formMode;
  Observable<String> get error => _error;
  Observable<bool> get isLoading => _isLoading;
  Observable<String> get popWithMessage => _popWithMessage;
  
  //Input functions
  changeMode() {
    if(_formMode.value == FormMode.login) {
      _formMode.sink.add(FormMode.signup);
    } else {
      _formMode.sink.add(FormMode.login);
    }
  }

  submit(String email, String password, String username) async {
    _isLoading.add(true);
    try {
      if (_formMode.value == FormMode.login) {
        await _authService.signIn(email, password);
      } else {
        if (await _firestoreService.checkUsername(username)) {
          var id = await _authService.signUp(email, password);
          await _firestoreService.addNewUser(id, username);
        } else {
          _error.sink.add('Username already exists');
          return;
        }
      }
      _popWithMessage.add('You logged in');
    }
    catch(error) {
      if(Platform.isIOS) {
        _error.sink.add(error.message);
      } else {
        _error.sink.add(error.details);
      }
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