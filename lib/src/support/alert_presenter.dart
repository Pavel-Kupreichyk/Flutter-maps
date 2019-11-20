import 'dart:async';
import 'package:flutter/material.dart';

enum ConfirmAction { cancel, accept }

class AlertPresenter {
  static Future<ConfirmAction> showPermissionDialog(BuildContext context) =>
      showCustomDialog(
          context,
          'Provide access to geolocation services',
          'To use this functionality of the app, provide access to geolocation services '
              'from the next dialog or from your settings if dialog wont appear.');

  static Future<ConfirmAction> showDisabledDialog(BuildContext context) =>
      showCustomDialog(context, 'Enable geolocation services',
          'To use this functionality of the app, you need to enable geolocation services.');

  static Future<ConfirmAction> showNotLoggedInDialog(BuildContext context) =>
      showCustomDialog(context, 'You are not logged in. ',
          'Please log in to use this functionality of app.');

  static Future<ConfirmAction> showErrorDialog(BuildContext context) =>
      showCustomDialog(
          context, 'Error', 'Unexpected error occurred. Please try again.');

  static Future<ConfirmAction> showCustomDialog(
      BuildContext context, String title, String data,
      [bool withDecline = false]) {
    return showDialog<ConfirmAction>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(data),
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
                withDecline
                    ? FlatButton(
                        child: Text('Decline'),
                        onPressed: () {
                          Navigator.of(context).pop(ConfirmAction.cancel);
                        },
                      )
                    : Container(),
              ],
            ));
  }

  static showStandardSnackBar(BuildContext context, String text) {
    var snackBar = SnackBar(
      content: Text(
        text,
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
