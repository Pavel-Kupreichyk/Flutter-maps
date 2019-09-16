import 'package:flutter/material.dart';

class AnimatedBottomMenu extends StatefulWidget {
  final bool isOpen;
  final Function() onFirstBtnPressed;
  final Function() onSecondBtnPressed;

  AnimatedBottomMenu(
      {this.isOpen = false, this.onFirstBtnPressed, this.onSecondBtnPressed});

  @override
  State<StatefulWidget> createState() => AnimatedBottomMenuState();
}

class AnimatedBottomMenuState extends State<AnimatedBottomMenu>
    with SingleTickerProviderStateMixin {
  final double menuHeight = 80;
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animation = Tween<double>(begin: menuHeight, end: 0).animate(_controller)
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
    return Transform.translate(
      offset: Offset(0, _animation.value),
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          height: menuHeight,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey,
                blurRadius: 20.0, // has the effect of softening the shadow
                spreadRadius: 4.0, // has the effect of extending the shadow
                offset: Offset(
                  8.0, // horizontal, move right 10
                  8.0, // vertical, move down 10
                ),
              )
            ],
            color: Colors.black54,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    height: menuHeight,
                    width: 60,
                    child: FlatButton(
                      child: Icon(Icons.image),
                      onPressed: () {
                        if (widget.onFirstBtnPressed != null) {
                          widget.onFirstBtnPressed();
                        }
                        _controller.reverse();
                      },
                    ),
                  ),
                  Container(
                    height: menuHeight,
                    width: 60,
                    child: FlatButton(
                      child: Icon(Icons.camera_alt),
                      onPressed: () {
                        if (widget.onFirstBtnPressed != null) {
                          widget.onSecondBtnPressed();
                        }
                        _controller.reverse();
                      },
                    ),
                  )
                ],
              ),
              Container(
                height: menuHeight,
                child: FlatButton(
                  child: Text('Hide Panel'),
                  onPressed: () => _controller.reverse(),
                ),
              )
            ],
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
