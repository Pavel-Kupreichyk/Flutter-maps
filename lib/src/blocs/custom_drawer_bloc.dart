import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/models/upload_snapshot.dart';
import 'package:flutter_maps/src/support/navigation_info.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/support/disposable.dart';
import 'package:rxdart/rxdart.dart';

class CustomDrawerBloc implements Disposable {
  final UploadManager _uploadManager;
  final AuthService _authService;

  BehaviorSubject<bool> _isUserLoggedIn = BehaviorSubject();
  PublishSubject<void> _userLoggedOut = PublishSubject();
  PublishSubject<NavigationInfo> _navigate = PublishSubject();

  CustomDrawerBloc(this._uploadManager, this._authService) {
    _getUser();
  }

  Observable<List<UploadSnapshot>> get snapshots => _uploadManager.snapshots;
  Observable<bool> get isUserLoggedIn => _isUserLoggedIn;
  Observable<void> get userLoggedOut => _userLoggedOut;
  Observable<NavigationInfo> get navigate => _navigate;

  removeUpload(String name) {
    _uploadManager.removeUpload(name);
  }

  moveToSettings() {
    _navigate.add(NavigationInfo.settings());
  }

  logOut() async {
    await _authService.signOut();
    _isUserLoggedIn.sink.add(false);
    _userLoggedOut.sink.add(null);
  }

  _getUser() async {
    var user = await _authService.getCurrentUser();
    if (user == null) {
      _isUserLoggedIn.sink.add(false);
    } else {
      _isUserLoggedIn.sink.add(true);
    }
  }

  @override
  void dispose() {
    _isUserLoggedIn.close();
    _userLoggedOut.close();
    _navigate.close();
  }
}
