import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_maps/src/models/upload_snapshot.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/support/disposable.dart';

class _Upload {
  final StorageUploadTask task;
  UploadSnapshot currSnapshot;
  StreamSubscription subscription;

  _Upload(this.task);

  void close() {
    subscription?.cancel();
    if (task.isInProgress) {
      task.cancel();
    }
  }
}

class UploadManager implements Disposable {
  final Map<String, _Upload> _uploads = {};

  final BehaviorSubject<List<UploadSnapshot>> _snapshots = BehaviorSubject();

  //Outputs
  Observable<List<UploadSnapshot>> get snapshots => _snapshots;

  void addFirebaseUpload(StorageUploadTask uploadTask, String name) {
    var upload = _Upload(uploadTask);
    upload.subscription = uploadTask.events.listen((event) {
      UploadState state;
      switch (event.type) {
        case StorageTaskEventType.progress:
          state = UploadState.progress;
          break;
        case StorageTaskEventType.success:
          state = UploadState.success;
          break;
        case StorageTaskEventType.pause:
          state = UploadState.pause;
          break;
        case StorageTaskEventType.failure:
          state = UploadState.failure;
          break;
        case StorageTaskEventType.resume:
          state = UploadState.progress;
          break;
      }
      upload.currSnapshot = UploadSnapshot(name, state,
          event.snapshot.totalByteCount, event.snapshot.bytesTransferred);
      _emitSnapshots();
    });
    _uploads[name] = upload;
  }

  void pauseUpload(String name) => _uploads[name].task.pause();

  void resumeUpload(String name) => _uploads[name].task.resume();

  void removeUpload(String name) {
    _uploads[name].close();
    _uploads.remove(name);
    _emitSnapshots();
  }

  void _emitSnapshots() => _snapshots.sink.add(_uploads.values
      .map((upload) => upload.currSnapshot)
      .where((el) => el != null)
      .toList());

  @override
  void dispose() {
    _snapshots.close();
  }
}
