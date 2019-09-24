import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/auth_bloc.dart';
import 'package:flutter_maps/src/managers/alert_presenter.dart';
import 'package:flutter_maps/src/services/auth_service.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';

import 'package:provider/provider.dart';

class AuthScreenBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<AuthService, AuthBloc>(
        builder: (_, auth, __) => AuthBloc(auth),
        dispose: (_, bloc) => bloc.dispose(),
        child: Consumer2<AuthBloc, AlertPresenter>(
          builder: (_, bloc, alert, __) => AuthScreen(bloc, alert),
        ));
  }
}

class AuthScreen extends StatefulWidget {
  static const route = '/auth';
  final AuthBloc bloc;
  final AlertPresenter alertPresenter;

  AuthScreen(this.bloc, this.alertPresenter);

  @override
  State<StatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends StateWithBag<AuthScreen> {
  final _formKey = new GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  void setupBindings() {
    bag += widget.bloc.success.listen((_) {
      widget.alertPresenter.showStandardSnackBar(context, 'You logged in');
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authentication'),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _showEmailInput(),
              _showPasswordInput(),
              _showPrimaryButton(),
              _showSecondaryButton(),
              _showErrorMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: const InputDecoration(
            hintText: 'Email',
            icon: const Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: const InputDecoration(
            hintText: 'Password',
            icon: const Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget _showPrimaryButton() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: MaterialButton(
          elevation: 5.0,
          minWidth: 200.0,
          height: 42.0,
          color: Colors.blue,
          child: StreamBuilder<FormMode>(
            stream: widget.bloc.formMode,
            builder: (_, snapshot) {
              if (snapshot.data == FormMode.login) {
                return const Text('Login',
                    style: TextStyle(fontSize: 20.0, color: Colors.white));
              } else {
                return const Text('Create account',
                    style: TextStyle(fontSize: 20.0, color: Colors.white));
              }
            },
          ),
          onPressed: _validateAndSubmit,
        ));
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: StreamBuilder<FormMode>(
        stream: widget.bloc.formMode,
        builder: (_, snapshot) {
          if (snapshot.data == FormMode.login) {
            return const Text('Create an account',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300));
          } else {
            return const Text('Have an account? Sign in',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300));
          }
        },
      ),
      onPressed: widget.bloc.changeMode,
    );
  }

  Widget _showErrorMessage() {
    return StreamBuilder<String>(
      stream: widget.bloc.error,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data,
            style: TextStyle(
                fontSize: 13.0,
                color: Colors.red,
                height: 1.0,
                fontWeight: FontWeight.w300),
          );
        }
        return Container();
      },
    );
  }

  _validateAndSubmit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      widget.bloc.submit(_email, _password);
    }
  }
}
