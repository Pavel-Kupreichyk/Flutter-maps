import 'package:flutter_maps/src/screens/screen_types.dart';
import 'package:rxdart/rxdart.dart';

class SnackBarManager {
  final PublishSubject<SnackBarData> _showSnackBar = PublishSubject();

  Observable<SnackBarData> get showSnackBar => _showSnackBar;

  pushSnackBar(ScreenType screen, String data) =>
      _showSnackBar.add(SnackBarData(screen, data));
}

class SnackBarData {
  final ScreenType screenType;
  final String data;
  SnackBarData(this.screenType, this.data);
}
