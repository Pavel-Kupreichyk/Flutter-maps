import 'dart:async';
import 'package:flutter_maps/src/support_classes/disposable.dart';

class DisposeBag implements Disposable{
  final List<StreamSubscription> _bag = [];

  DisposeBag operator +(StreamSubscription subscription) {
    _bag.add(subscription);
    return this;
  }

  @override
  void dispose() {
    _bag.forEach((subscription) {
      subscription.cancel();
    });
    _bag.clear();
  }
}