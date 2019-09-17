import 'package:flutter_maps/src/support_classes/dispose_bag.dart';
import 'package:flutter/material.dart';

abstract class StateWithBag<T extends StatefulWidget> extends State<T> {
  DisposeBag bag = DisposeBag();

  void setupBindings();

  bool shouldRebindAfterUpdate(T oldWidget) {
    return true;
  }

  @override
  void initState() {
    setupBindings();
    super.initState();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    if(shouldRebindAfterUpdate(oldWidget)) {
      bag.dispose();
      setupBindings();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    bag.dispose();
    super.dispose();
  }

}
