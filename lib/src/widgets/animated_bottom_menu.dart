import 'package:flutter/material.dart';

enum ButtonType { camera, gallery, remove }

class AnimatedBottomMenu extends StatefulWidget {
  final bool isOpen;
  final Function(ButtonType) onButtonPressed;

  AnimatedBottomMenu({
    this.isOpen = false,
    this.onButtonPressed,
  });

  @override
  State<StatefulWidget> createState() => AnimatedBottomMenuState();
}

class AnimatedBottomMenuState extends State<AnimatedBottomMenu>
    with SingleTickerProviderStateMixin {
  static const double _menuHeight = 80;
  static const double _blurRadius = 20;
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animation = Tween<double>(begin: _menuHeight + _blurRadius, end: 0)
        .animate(_controller);
    widget.isOpen ? _controller.forward() : _controller.reverse();
  }

  @override
  void didUpdateWidget(AnimatedBottomMenu oldWidget) {
    widget.isOpen ? _controller.forward() : _controller.reverse();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, panel) {
        if (_animation.value == (_menuHeight + _blurRadius)) {
          return Container();
        }
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: panel,
        );
      },
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          height: _menuHeight,
          decoration: BoxDecoration(
            color: theme.bottomAppBarColor,
            boxShadow: [
              BoxShadow(
                color: theme.accentColor,
                blurRadius: _blurRadius,
                spreadRadius: 1.0,
                offset: Offset(
                  8.0,
                  8.0,
                ),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _buildMenuButton(
                      width: 60,
                      child: const Icon(Icons.image),
                      buttonType: ButtonType.gallery,
                    ),
                    _buildMenuButton(
                      width: 60,
                      child: const Icon(Icons.camera_alt),
                      buttonType: ButtonType.camera,
                    ),
                    _buildMenuButton(
                      width: 60,
                      child: const Icon(Icons.close),
                      buttonType: ButtonType.remove,
                    ),
                  ],
                ),
                _buildMenuButton(
                  child: const Text('Hide Panel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({Widget child, double width, ButtonType buttonType}) {
    return Container(
      height: _menuHeight,
      width: width,
      child: FlatButton(
        child: child,
        onPressed: () {
          if (widget.onButtonPressed != null && buttonType != null) {
            widget.onButtonPressed(buttonType);
          }
          _controller.reverse();
        },
      ),
    );
  }
}
