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
  static const double menuHeight = 80;
  static const double blurRadius = 20;
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animation = Tween<double>(begin: menuHeight + blurRadius, end: 0)
        .animate(_controller)
          ..addListener(() => setState(() {}));
    _animateMenu();
  }

  @override
  void didUpdateWidget(AnimatedBottomMenu oldWidget) {
    _animateMenu();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_animation.value == (menuHeight + blurRadius)) {
      return Container();
    }

    return Transform.translate(
      offset: Offset(0, _animation.value),
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          height: menuHeight,
          decoration: BoxDecoration(
            boxShadow: [
              const BoxShadow(
                color: Colors.blueGrey,
                blurRadius: blurRadius,
                spreadRadius: 4.0,
                offset: Offset(
                  8.0,
                  8.0,
                ),
              )
            ],
            color: Colors.black54,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _MenuButton(
                      width: 60,
                      height: menuHeight,
                      child: const Icon(Icons.image),
                      onClick: () {
                        if (widget.onButtonPressed != null) {
                          widget.onButtonPressed(ButtonType.gallery);
                        }
                        _controller.reverse();
                      },
                    ),
                    _MenuButton(
                      width: 60,
                      height: menuHeight,
                      child: const Icon(Icons.camera_alt),
                      onClick: () {
                        if (widget.onButtonPressed != null) {
                          widget.onButtonPressed(ButtonType.camera);
                        }
                        _controller.reverse();
                      },
                    ),
                    _MenuButton(
                      width: 60,
                      height: menuHeight,
                      child: const Icon(Icons.close),
                      onClick: () {
                        if (widget.onButtonPressed != null) {
                          widget.onButtonPressed(ButtonType.remove);
                        }
                        _controller.reverse();
                      },
                    ),
                  ],
                ),
                _MenuButton(
                  height: menuHeight,
                  child: const Text('Hide Panel'),
                  onClick: _controller.reverse,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _animateMenu() {
    if (widget.isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
}

class _MenuButton extends StatelessWidget {
  final double height;
  final double width;
  final Widget child;
  final Function onClick;

  _MenuButton({this.child, this.height, this.width, this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: FlatButton(
        child: child,
        onPressed: onClick,
      ),
    );
  }
}
