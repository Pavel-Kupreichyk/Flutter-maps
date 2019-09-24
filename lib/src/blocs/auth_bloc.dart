import 'dart:io';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';

enum FormMode { login, signup }

class AuthBloc implements Disposable {
  final AuthService _authService;

  BehaviorSubject<FormMode> _formMode = BehaviorSubject.seeded(FormMode.login);
  BehaviorSubject<String> _error = BehaviorSubject();
  PublishSubject<void> _success = PublishSubject();

  AuthBloc(this._authService);

  //Outputs
  Observable<FormMode> get formMode => _formMode;
  Observable<String> get error => _error;
  Observable<void> get success => _success;

  //Input functions

  changeMode() {
    if(_formMode.value == FormMode.login) {
      _formMode.sink.add(FormMode.signup);
    } else {
      _formMode.sink.add(FormMode.login);
    }
  }

  submit(String email, String password) async {
    try {
      if (_formMode.value == FormMode.login) {
        await _authService.signIn(email, password);
        _success.sink.add(null);
      } else {
        await _authService.signUp(email, password);
        _success.sink.add(null);
      }
    }
    catch(error) {
      if(Platform.isIOS) {
        _error.sink.add(error.message);
      } else {
        _error.sink.add(error.details);
      }
    }
  }

  @override
  void dispose() {
    _formMode.close();
    _error.close();
    _success.close();
  }
}