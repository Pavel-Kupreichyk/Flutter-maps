import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/models/upload_snapshot.dart';
import 'package:flutter_maps/src/support/navigation_info.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/support/disposable.dart';
import 'package:rxdart/rxdart.dart';

class CustomDrawerBloc implements Disposable {
  final UploadManager _uploadManager;
  final AuthService _authService;

  final BehaviorSubject<bool> _isUserLoggedIn = BehaviorSubject();
  final PublishSubject<void> _userLoggedOut = PublishSubject();
  final PublishSubject<NavigationInfo> _navigate = PublishSubject();

  CustomDrawerBloc(this._uploadManager, this._authService) {
    _getUser();
  }

  Observable<List<UploadSnapshot>> get snapshots => _uploadManager.snapshots;
  Observable<bool> get isUserLoggedIn => _isUserLoggedIn;
  Observable<void> get userLoggedOut => _userLoggedOut;
  Observable<NavigationInfo> get navigate => _navigate;

  void removeUpload(String name) => _uploadManager.removeUpload(name);

  void moveToSettings() => _navigate.add(NavigationInfo.settings());

  Future logOut() async {
    await _authService.signOut();
    _isUserLoggedIn.add(false);
    _userLoggedOut.add(null);
  }

  Future _getUser() async {
    var user = await _authService.getCurrentUser();
    if (user == null) {
      _isUserLoggedIn.add(false);
    } else {
      _isUserLoggedIn.add(true);
    }
  }

  @override
  void dispose() {
    _isUserLoggedIn.close();
    _userLoggedOut.close();
    _navigate.close();
  }
}
