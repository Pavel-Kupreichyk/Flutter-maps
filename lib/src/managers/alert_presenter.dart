import 'dart:async';
import 'package:flutter/material.dart';

enum ConfirmAction { cancel, accept }

class AlertPresenter {
  Future<ConfirmAction> showPermissionDialog(BuildContext context) {
    return showDialog<ConfirmAction>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text('Provide access to geolocation services'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                        'To use this functionality of the app, provide access to geolocation services from the next dialog or from your settings if dialog doesn\'t appear.'),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop(ConfirmAction.accept);
                  },
                ),
              ],
            ));
  }

  Future<ConfirmAction> showDisabledDialog(BuildContext context) {
    return showDialog<ConfirmAction>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text('Enable geolocation services'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                        'To use this functionality of the app, you need to enable geolocation services.'),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop(ConfirmAction.accept);
                  },
                ),
              ],
            ));
  }

  Future<ConfirmAction> showErrorDialog(BuildContext context) {
    return showDialog<ConfirmAction>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text('Error'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Unexpected error occurred. Please try again.'),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop(ConfirmAction.accept);
                  },
                ),
              ],
            ));
  }
}
