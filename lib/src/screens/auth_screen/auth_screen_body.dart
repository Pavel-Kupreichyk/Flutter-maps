import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/auth_bloc.dart';
import 'package:flutter_maps/src/support/bindable_state.dart';

class AuthScreenBody extends StatefulWidget {
  final AuthBloc bloc;
  AuthScreenBody(this.bloc);

  @override
  State<StatefulWidget> createState() => _AuthScreenBodyState();
}

class _AuthScreenBodyState extends BindableState<AuthScreenBody> {
  final _formKey = new GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';

  @override
  void setupBindings() {
    bag +=
        widget.bloc.popWithMessage.listen((msg) => Navigator.pop(context, msg));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _showEmailInput(),
              _showPasswordInput(),
              StreamBuilder<FormMode>(
                stream: widget.bloc.formMode,
                builder: (_, snapshot) {
                  if (snapshot.hasData && snapshot.data == FormMode.signup) {
                    return _showUsernameInput();
                  }
                  return Container();
                },
              ),
              _showPrimaryButton(Theme.of(context)),
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
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
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

  Widget _showUsernameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        autofocus: false,
        decoration: const InputDecoration(
            hintText: 'Username',
            icon: const Icon(
              Icons.person,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
        onSaved: (value) => _username = value.trim(),
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

  Widget _showPrimaryButton(ThemeData theme) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: StreamBuilder<bool>(
          stream: widget.bloc.isLoading,
          builder: (_, snapshot) {
            final isLoading = snapshot.data ?? false;
            return RaisedButton(
              elevation: 3.0,
              color: theme.accentColor,
              child: StreamBuilder<FormMode>(
                stream: widget.bloc.formMode,
                builder: (_, snapshot) {
                  if (snapshot.data == FormMode.login) {
                    return Text('Login',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: theme.accentTextTheme.title.color));
                  } else {
                    return Text('Create account',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: theme.accentTextTheme.title.color));
                  }
                },
              ),
              onPressed: isLoading ? null : _validateAndSubmit,
            );
          },
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
                fontSize: 14,
                color: Colors.red,
                height: 1.0,
                fontWeight: FontWeight.w500),
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
      widget.bloc.submit(_email, _password, _username.toLowerCase());
    }
  }
}
