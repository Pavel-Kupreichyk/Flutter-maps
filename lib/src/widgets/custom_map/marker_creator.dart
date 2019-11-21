import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support/disposable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class _MarkerInfo {
  Marker marker;
  Function() loadCompleter;
}

class MarkerCreator implements Disposable {
  final Map<Place, _MarkerInfo> _placeMarker = {};
  final BehaviorSubject<Set<Marker>> _markersSubject =
      BehaviorSubject.seeded({});
  ui.Image _placeholder;
  Future<Function()> _placeholderCompleter;

  MarkerCreator() {
    _placeholderCompleter = _loadImage(
        AssetImage('images/placeholder.png'), (image) => _placeholder = image);
  }

  Observable<Set<Marker>> get markers => _markersSubject;

  createMarkers(List<Place> places) {
    var toLoad = places.where((p) => !_placeMarker.keys.contains(p));
    var toDelete =
        List<Place>.from(_placeMarker.keys.where((p) => !places.contains(p)));
    if (toDelete.length > 0) {
      toDelete.forEach(_removeMarker);
      _markersSubject.add(_placeMarker.values
          .map((v) => v.marker)
          .where((v) => v != null)
          .toSet());
    }
    toLoad.forEach(_loadImageAndCreateMarker);
  }

  Future<Function()> _loadImage(
      ImageProvider provider, Function(ui.Image) func) async {
    var load = provider.load(await provider.obtainKey(ImageConfiguration()));
    var listener = ImageStreamListener((info, _) => func(info.image));
    load.addListener(listener);
    return () => load.removeListener(listener);
  }

  _loadImageAndCreateMarker(Place place) async {
    _placeMarker[place] = _MarkerInfo();
    if (_placeholder != null) {
      await _createMarker(place, _placeholder);
    } else if (place.imageUrl == null) {
      var remover = await _loadImage(AssetImage('images/placeholder.png'),
          (image) => _createMarker(place, image));
      _placeMarker[place]?.loadCompleter = remover;
    }

    if (place.imageUrl != null) {
      var remover = await _loadImage(CachedNetworkImageProvider(place.imageUrl),
          (image) => _createMarker(place, image));
      _placeMarker[place]?.loadCompleter = remover;
    }
  }

  _createMarker(Place place, ui.Image image) async {
    final Uint8List markerIcon = await _drawMarker(120, image);
    var marker = Marker(
        markerId: MarkerId(place.name),
        infoWindow: InfoWindow(title: place.name),
        position: LatLng(place.lat, place.lng),
        icon: BitmapDescriptor.fromBytes(markerIcon));
    _addMarker(place, marker);
  }

  _addMarker(Place place, Marker marker) {
    _placeMarker[place].marker = marker;
    _markersSubject.add(_placeMarker.values
        .map((v) => v.marker)
        .where((v) => v != null)
        .toSet());
  }

  _removeMarker(Place place) {
    if (_placeMarker[place].loadCompleter != null) {
      _placeMarker[place].loadCompleter();
    }
    _placeMarker.remove(place);
  }

  Future<Uint8List> _drawMarker(int height, ui.Image image) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final int width = (height * 0.7).toInt();
    final pointerRadius = height / 14;
    final center = Offset(width / 2, height - pointerRadius);
    double imgSize = min(image.height, image.width).toDouble();

    Paint paintCircle = Paint()..color = Colors.black;
    Paint paintBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = width / 40
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, pointerRadius, paintCircle);
    canvas.drawCircle(center, pointerRadius, paintBorder);

    Path path = Path()
      ..addOval(Rect.fromLTWH(0, 0, width.toDouble(), height * 0.7));

    canvas.clipPath(path);
    canvas.drawImageRect(
        image,
        Rect.fromCenter(
            center: Offset(image.width / 2, image.height / 2),
            width: imgSize,
            height: imgSize),
        Rect.fromLTWH(0, 0, width.toDouble(), height * 0.7),
        Paint());

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  @override
  void dispose() {
    for (var val in _placeMarker.values) {
      if (val.loadCompleter != null) {
        val.loadCompleter();
      }
    }
    _placeholderCompleter.then((f) => f());
  }
}
