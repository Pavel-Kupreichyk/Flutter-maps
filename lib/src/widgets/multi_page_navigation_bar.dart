import 'package:flutter/material.dart';
import 'package:flutter_maps/src/managers/route_manager.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';

class MultiPageNavBar extends StatefulWidget {
  final Widget child;
  final RouteManager routeManager;
  MultiPageNavBar(this.routeManager, {this.child});

  @override
  State<StatefulWidget> createState() => MultiPageNavBarState();
}

class MultiPageNavBarState extends State<MultiPageNavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: StreamBuilder<Route>(
          stream: widget.routeManager.route,
          builder: (_, snapshot) {
            bool isFirstPage = snapshot.data?.isFirst ?? true;
            return isFirstPage ? _buildDrawerButton() : _buildBackButton();
          },
        ),
      ),
      drawer: Drawer(),
      body: widget.child,
    );
  }

  Widget _buildDrawerButton() {
    return IconButton(
      icon: Icon(Icons.list),
      onPressed: () => _scaffoldKey.currentState.openDrawer(),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => widget.routeManager.navigator.pop(),
    );
  }
}
