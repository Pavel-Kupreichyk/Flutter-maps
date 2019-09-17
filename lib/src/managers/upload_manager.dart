import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_maps/src/models/upload_snapshot.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';

class UploadManager implements Disposable {
  final Map<String, UploadSnapshot> _currSnapshots = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, StorageUploadTask> _tasks = {};

  BehaviorSubject<List<UploadSnapshot>> _snapshots = BehaviorSubject();

  //Outputs
  Observable<List<UploadSnapshot>> get snapshot => _snapshots;

  addFirebaseUpload(StorageUploadTask uploadTask, String name) {
    _tasks[name] = uploadTask;
    _subscriptions[name] = uploadTask.events.listen((event) {
      UploadState state;
      switch (event.type) {
        case StorageTaskEventType.progress:
          state = UploadState.progress;

          print('progress');
          break;
        case StorageTaskEventType.success:
          state = UploadState.success;
          print('success');
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
      print('${event.snapshot.bytesTransferred}/${event.snapshot.totalByteCount}');

      _currSnapshots[name] = UploadSnapshot(name, state,
          event.snapshot.totalByteCount, event.snapshot.bytesTransferred);
      _snapshots.sink.add(_currSnapshots.values.toList());
    });
  }

  pauseUpload(String name) {
    _tasks[name].pause();
  }

  resumeUpload(String name) {
    _tasks[name].resume();
  }

  removeUpload(String name) {
    _subscriptions[name].cancel();
    _tasks[name].cancel();
    _currSnapshots.remove(name);
  }

  @override
  void dispose() {
    _snapshots.close();
  }
}
