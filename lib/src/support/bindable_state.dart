import 'package:flutter_maps/src/support/dispose_bag.dart';
import 'package:flutter/material.dart';

abstract class BindableState<T extends StatefulWidget> extends State<T> {
  DisposeBag bag = DisposeBag();

  void setupBindings();

  bool shouldRebindAfterUpdate(T oldWidget) => false;

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
