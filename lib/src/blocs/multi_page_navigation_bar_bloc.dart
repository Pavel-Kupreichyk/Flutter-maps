import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/models/upload_snapshot.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';
import 'package:rxdart/rxdart.dart';

class MultiPageNavBarBloc implements Disposable {
  final UploadManager _uploadManager;

  MultiPageNavBarBloc(this._uploadManager);

  Observable<List<UploadSnapshot>> get snapshots => _uploadManager.snapshots;


  removeUpload(String name) {
    _uploadManager.removeUpload(name);
  }

  @override
  void dispose() {
  }
}