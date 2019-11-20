import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/place_add_edit_bloc.dart';
import 'package:flutter_maps/src/support/alert_presenter.dart';
import 'package:flutter_maps/src/support/bindable_state.dart';
import 'package:flutter_maps/src/widgets/animated_bottom_menu.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEditScreenBody extends StatefulWidget {
  final AddEditPlaceBloc bloc;

  AddEditScreenBody(this.bloc);

  @override
  State<StatefulWidget> createState() => _AddEditScreenBodyState();
}

class _AddEditScreenBodyState extends BindableState<AddEditScreenBody> {
  @override
  void setupBindings() {
    bag += widget.bloc.error.listen((error) {
      switch (error) {
        case AddEditPlaceBlocError.permissionNotProvided:
          _requestPermission();
          break;
        case AddEditPlaceBlocError.servicesDisabled:
          AlertPresenter.showDisabledDialog(context);
          break;
        case AddEditPlaceBlocError.notLoggedIn:
          AlertPresenter.showNotLoggedInDialog(context);
          break;
        case AddEditPlaceBlocError.unexpectedError:
          AlertPresenter.showErrorDialog(context);
          break;
      }
    });
    bag +=
        widget.bloc.popWithMessage.listen((msg) => Navigator.pop(context, msg));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Stack(
        children: <Widget>[
          SafeArea(
            child: ListView(
              children: <Widget>[
                Center(
                  child: StreamBuilder<File>(
                    stream: widget.bloc.image,
                    builder: (_, snapshot) {
                      return _buildImageView(snapshot.data);
                    },
                  ),
                ),
                Center(
                  child: _PlaceTextForm(widget.bloc),
                ),
              ],
            ),
          ),
          StreamBuilder<bool>(
            stream: widget.bloc.bottomMenuState,
            builder: (_, snapshot) {
              return AnimatedBottomMenu(
                isOpen: snapshot.data ?? false,
                onButtonPressed: (type) {
                  switch (type) {
                    case ButtonType.camera:
                      widget.bloc.addImage(ImageSource.camera);
                      break;
                    case ButtonType.gallery:
                      widget.bloc.addImage(ImageSource.gallery);
                      break;
                    case ButtonType.remove:
                      widget.bloc.removeImage();
                      break;
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  _requestPermission() async {
    await AlertPresenter.showPermissionDialog(context);
    widget.bloc.requestLocationPermission();
  }

  Widget _buildImageView([File image]) {
    return Stack(
      children: <Widget>[
        Container(
          width: 250,
          child: AspectRatio(
            aspectRatio: 1,
            child: image == null
                ? Image.asset('images/placeholder.png', fit: BoxFit.cover)
                : Image.file(image, fit: BoxFit.cover),
          ),
        ),
        FloatingActionButton(
          heroTag: 'unique1',
          child: const Icon(
            Icons.add,
          ),
          shape: RoundedRectangleBorder(
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(16))),
          onPressed: () => widget.bloc.addPhotoButtonPressed(),
        ),
      ],
    );
  }
}

class _PlaceTextForm extends StatefulWidget {
  final AddEditPlaceBloc bloc;
  _PlaceTextForm(this.bloc);
  @override
  State<StatefulWidget> createState() => _PlaceTextFormState();
}

class _PlaceTextFormState extends BindableState<_PlaceTextForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  @override
  void setupBindings() {
    bag += widget.bloc.place.listen((place) {
      _nameController.value = TextEditingValue(text: place?.name ?? '');
      _aboutController.value = TextEditingValue(text: place?.about ?? '');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              controller: _nameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'About',
              ),
              controller: _aboutController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: StreamBuilder<bool>(
                stream: widget.bloc.isLoading,
                builder: (_, snapshot) {
                  var isLoading = snapshot.data ?? false;
                  return Row(
                    children: <Widget>[
                      RaisedButton(
                        color: theme.accentColor,
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState.validate()) {
                                  widget.bloc.addPlace(_nameController.text,
                                      _aboutController.text);
                                }
                              },
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              color: theme.accentTextTheme.title.color),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          height: 25,
                          width: 25,
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : null,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
