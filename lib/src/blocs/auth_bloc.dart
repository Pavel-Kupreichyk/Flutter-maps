import 'dart:io';
import 'package:flutter_maps/src/managers/snack_bar_manager.dart';
import 'package:flutter_maps/src/managers/navigation_manager.dart';
import 'package:flutter_maps/src/screens/screen_types.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';

enum FormMode { login, signup }

class AuthBloc implements Disposable {
  final AuthService _authService;
  final SnackBarManager _alertManager;
  final NavigationManager _navigationManager;

  BehaviorSubject<FormMode> _formMode = BehaviorSubject.seeded(FormMode.login);
  BehaviorSubject<String> _error = BehaviorSubject();

  AuthBloc(this._authService, this._navigationManager, this._alertManager);

  //Outputs
  Observable<FormMode> get formMode => _formMode;
  Observable<String> get error => _error;

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
      } else {
        await _authService.signUp(email, password);
      }
      _alertManager.pushSnackBar(ScreenType.main, 'You logged in');
      _navigationManager.popCurrent();
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
  }
}