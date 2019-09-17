import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';

class RouteManager extends NavigatorObserver implements Disposable{

  BehaviorSubject<Route> _route = BehaviorSubject();
  Observable<Route> get route => _route;

  @override
  void didPop(Route route, Route previousRoute) {
    _route.sink.add(previousRoute);
  }

  @override
  void didPush(Route route, Route previousRoute) {
    _route.sink.add(route);
  }

  @override
  void dispose() {
    _route.close();
  }
}