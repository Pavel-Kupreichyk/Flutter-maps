import 'package:flutter/material.dart';

enum Layout { slim, wide }

typedef CustomLayoutWidgetBuilder = Widget Function(
    BuildContext context, Layout layout, BoxConstraints constraints);

class CustomLayoutBuilder extends StatelessWidget {
  const CustomLayoutBuilder({
    @required this.builder,
    Key key,
  })  : assert(builder != null),
        super(key: key);

  final CustomLayoutWidgetBuilder builder;

  Widget _build(BuildContext context, BoxConstraints constraints) {
    var mediaWidth = MediaQuery.of(context).size.width;
    var mediaHeight = MediaQuery.of(context).size.height;
    Layout layout = mediaWidth <= mediaHeight ? Layout.slim : Layout.wide;
    return builder(context, layout, constraints);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _build);
  }
}
