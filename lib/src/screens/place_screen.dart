import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/place_screen_bloc.dart';
import 'package:flutter_maps/src/managers/alert_manager.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/widgets/place_text_form.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';
import 'package:flutter_maps/src/widgets/animated_bottom_menu.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEditPlaceScreen extends StatefulWidget {
  final AddEditPlaceBloc bloc;
  final AlertManager alertManager;

  AddEditPlaceScreen(this.bloc, this.alertManager);

  @override
  State<StatefulWidget> createState() => _AddEditPlaceScreenState();
}

class _AddEditPlaceScreenState extends StateWithBag<AddEditPlaceScreen> {
  @override
  void setupBindings() {
    bag += widget.bloc.navigation.listen((navInfo) {
      Navigator.pushNamed(context, navInfo.route, arguments: navInfo.args);
    });

    bag += widget.bloc.error.listen((error) {
      switch (error) {
        case AddEditPlaceBlocError.permissionNotProvided:
          _requestPermission();
          break;
        case AddEditPlaceBlocError.servicesDisabled:
          widget.alertManager.showDisabledDialog(context);
          break;
        case AddEditPlaceBlocError.unexpectedError:
          widget.alertManager.showErrorDialog(context);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder<File>(
                stream: widget.bloc.image,
                builder: (_, snapshot) {
                  return _buildImageView(snapshot.data);
                },
              ),
              StreamBuilder<Place>(
                stream: widget.bloc.place,
                builder: (_, snapshot) {
                  return PlaceTextForm(
                      place: snapshot.data, onSubmit: widget.bloc.updatePlaces);
                },
              ),
            ],
          ),
          StreamBuilder<bool>(
            stream: widget.bloc.bottomMenuState,
            builder: (_, snapshot) {
              return AnimatedBottomMenu(
                isOpen: snapshot.data ?? false,
                onFirstBtnPressed: () =>
                    widget.bloc.addImage(ImageSource.gallery),
                onSecondBtnPressed: () =>
                    widget.bloc.addImage(ImageSource.camera),
              );
            },
          ),
        ],
      ),
    );
  }

  _requestPermission() async {
    await widget.alertManager.showPermissionDialog(context);
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
          child: Icon(Icons.add),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(16))),
          onPressed: () => widget.bloc.addPhotoButtonPressed(),
        ),
      ],
    );
  }
}
