import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/models/upload_snapshot.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';
import 'package:rxdart/rxdart.dart';

class CustomDrawerBloc implements Disposable {
  final UploadManager _uploadManager;
  final AuthService _authService;

  BehaviorSubject<bool> _isUserLoggedIn = BehaviorSubject();
  PublishSubject<void> _userLoggedOut = PublishSubject();

  CustomDrawerBloc(this._uploadManager, this._authService) {
    _getUser();
  }

  Observable<List<UploadSnapshot>> get snapshots => _uploadManager.snapshots;
  Observable<bool> get isUserLoggedIn => _isUserLoggedIn;
  Observable<void> get userLoggedOut => _userLoggedOut;

  removeUpload(String name) {
    _uploadManager.removeUpload(name);
  }

  logOut() async {
    await _authService.signOut();
    _isUserLoggedIn.sink.add(false);
    _userLoggedOut.sink.add(null);
  }

  _getUser() async {
    var user = await _authService.getCurrentUser();
    if(user == null) {
      _isUserLoggedIn.sink.add(false);
    } else {
      _isUserLoggedIn.sink.add(true);
    }
  }

  @override
  void dispose() {
    _isUserLoggedIn.close();
    _userLoggedOut.close();
  }
}