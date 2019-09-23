import 'package:flutter/material.dart';
import 'package:flutter_maps/src/models/upload_snapshot.dart';

class CustomProgressBar extends StatefulWidget {
  final UploadSnapshot snapshot;
  final String measureName;
  final double measureDivider;
  final Function onRemoveButtonPressed;

  CustomProgressBar(this.snapshot,
      {this.measureName = '',
      this.measureDivider = 1,
      this.onRemoveButtonPressed});

  @override
  State<StatefulWidget> createState() => _CustomProgressBarState();
}

class _CustomProgressBarState extends State<CustomProgressBar>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, value: _calcPercent())
      ..addListener(() {
        setState(() {});
      });
    controller.animateTo(_calcPercent(), duration: Duration(milliseconds: 250));
  }

  @override
  void didUpdateWidget(CustomProgressBar oldWidget) {
    controller.animateTo(_calcPercent(), duration: Duration(milliseconds: 250));
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              widget.snapshot.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_statusDesc())
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue,
            ),
            value: controller.value,
          ),
        ),
        FlatButton(
          child: _buttonDesc(),
          highlightColor: Colors.transparent,
          onPressed: () {
            if (widget.onRemoveButtonPressed != null) {
              widget.onRemoveButtonPressed();
            }
          },
        ),
      ],
    );
  }

  String _transformToString(int value) {
    return (value / widget.measureDivider).toStringAsFixed(2);
  }

  double _calcPercent() {
    return widget.snapshot.transferredBytes / widget.snapshot.totalBytes;
  }

  String _statusDesc() {
    switch (widget.snapshot.state) {
      case UploadState.progress:
        return '${_transformToString(widget.snapshot.transferredBytes)}/${_transformToString(widget.snapshot.totalBytes)} ${widget.measureName}';
      case UploadState.failure:
        return 'Failure';
      case UploadState.success:
        return 'Done';
      case UploadState.pause:
        return 'Pause';
    }
    return '';
  }

  Widget _buttonDesc() {
    switch (widget.snapshot.state) {
      case UploadState.progress:
      case UploadState.pause:
        return Text(
          'Cancel',
          style: TextStyle(color: Colors.grey),
        );
      case UploadState.failure:
      case UploadState.success:
        return Text(
          'Remove',
          style: TextStyle(color: Colors.grey),
        );
    }
    return Container();
  }
}
