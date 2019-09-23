import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/main_bloc.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';

class CustomMap extends StatefulWidget {
  final List<Place> places;
  final MainBloc bloc;
  CustomMap(this.bloc, {this.places = const []});

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends StateWithBag<CustomMap> {
  final Set<Marker> _markers = {};
  static const LatLng blr = LatLng(53.9, 27.56667);
  GoogleMapController mapController;

  final Map<ImageStreamCompleter, ImageStreamListener> _imageStreams = {};

  @override
  void setupBindings() {
    bag += widget.bloc.location.listen((location) {
      mapController?.animateCamera(
        CameraUpdate.newLatLng(location),
      );
    });
  }

  @override
  void initState() {
    widget.places.forEach((place) => _loadImageAndCreateMarker(place));
    super.initState();
  }

  @override
  void didUpdateWidget(CustomMap oldWidget) {
    _markers.clear();
    _imageStreams.forEach((key, val) => key.removeListener(val));
    _imageStreams.clear();
    widget.places.forEach((place) => _loadImageAndCreateMarker(place));
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _imageStreams.forEach((key, val) => key.removeListener(val));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(target: blr, zoom: 9),
      myLocationButtonEnabled: false,
      onMapCreated: (controller) => mapController = controller,
      markers: _markers,
    );
  }

  _loadImageAndCreateMarker(Place place) async {
    var provider = CachedNetworkImageProvider(place.imageUrl);
    var load = provider.load(await provider.obtainKey(ImageConfiguration()));
    var listener =
        ImageStreamListener((info, _) => _addMarkerToList(place, info.image));
    load.addListener(listener);
    _imageStreams[load] = listener;
  }

  _addMarkerToList(Place place, ui.Image image) async {
    final Uint8List markerIcon = await _createMarker(120, image);
    var marker = Marker(
        markerId: MarkerId(place.name),
        infoWindow: InfoWindow(title: place.name, snippet: place.about),
        position: LatLng(place.lat, place.lng),
        icon: BitmapDescriptor.fromBytes(markerIcon));

    setState(() {
      _markers.add(marker);
    });
  }

  Future<Uint8List> _createMarker(int height, ui.Image image) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final int width = (height * 0.7).toInt();
    final pointerRadius = height / 14;
    final center = Offset(width / 2, height - pointerRadius);

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
            width: 750,
            height: 750),
        Rect.fromLTWH(0, 0, width.toDouble(), height * 0.7),
        Paint());

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }
}
