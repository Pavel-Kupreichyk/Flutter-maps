import 'package:flutter/material.dart';
import 'package:flutter_maps/src/models/place.dart';

class PlaceTextForm extends StatefulWidget {
  final Place place;
  final Function(String name, String about) onSubmit;

  PlaceTextForm({this.place, this.onSubmit});

  @override
  State<StatefulWidget> createState() => PlaceTextFormState();
}

class PlaceTextFormState extends State<PlaceTextForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController;
  TextEditingController _aboutController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.place?.name ?? '');
    _aboutController = TextEditingController(text: widget.place?.about ?? '');
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              keyboardType:  TextInputType.multiline,
              maxLines: null,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    if (widget.onSubmit != null) {
                      widget.onSubmit(_nameController.text, _aboutController.text);
                    }
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}