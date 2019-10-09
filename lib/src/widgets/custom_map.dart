import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';
import 'package:rxdart/rxdart.dart';

class CustomMap extends StatefulWidget {
  final List<Place> places;
  final LatLng startLocation;
  final double startZoom;
  final Stream<LatLng> locationUpdater;
  final bool gesturesEnabled;

  CustomMap(
      {this.places = const [],
      Key key,
      this.startLocation = const LatLng(53.9, 27.56667),
      this.startZoom = 11,
      this.locationUpdater,
      this.gesturesEnabled = true})
      : super(key: key);

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends StateWithBag<CustomMap> {
  final MarkerCreator markerCreator = MarkerCreator();
  GoogleMapController mapController;

  @override
  void setupBindings() {
    if (widget.locationUpdater != null) {
      bag += widget.locationUpdater.listen((location) {
        mapController?.animateCamera(
          CameraUpdate.newLatLng(location),
        );
      });
    }
  }

  @override
  void initState() {
    markerCreator.createMarkers(widget.places);
    super.initState();
  }

  @override
  void didUpdateWidget(CustomMap oldWidget) {
    markerCreator.createMarkers(widget.places);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    markerCreator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<Marker>>(
      stream: markerCreator.markers,
      builder: (_, snapshot) {
        final Set<Marker> markers = snapshot.hasData ? snapshot.data : {};
        return GoogleMap(
          initialCameraPosition: CameraPosition(
              target: widget.startLocation, zoom: widget.startZoom),
          myLocationButtonEnabled: false,
          onMapCreated: (controller) => mapController = controller,
          scrollGesturesEnabled: widget.gesturesEnabled,
          rotateGesturesEnabled: widget.gesturesEnabled,
          zoomGesturesEnabled: widget.gesturesEnabled,
          markers: markers,
        );
      },
    );
  }
}

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
    _refreshMarkers(places);
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
        infoWindow: InfoWindow(title: place.name, snippet: place.about),
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

  _refreshMarkers(List<Place> places) {
    var toLoad = places.where((p) => !_placeMarker.keys.contains(p));
    var toDelete = _placeMarker.keys.where((p) => !places.contains(p));
    if (toDelete.length > 0) {
      toDelete.forEach(_removeMarker);
      _markersSubject.add(_placeMarker.values
          .map((v) => v.marker)
          .where((v) => v != null)
          .toSet());
    }
    toLoad.forEach(_loadImageAndCreateMarker);
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
