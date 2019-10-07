import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/main_bloc.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/support_classes/disposable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_maps/src/support_classes/state_with_bag.dart';
import 'package:rxdart/rxdart.dart';

class CustomMap extends StatefulWidget {
  final List<Place> places;
  final MainBloc bloc;
  CustomMap(this.bloc, {this.places = const []});

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends StateWithBag<CustomMap> {
  final MarkerCreator markerCreator = MarkerCreator();
  static const LatLng blr = LatLng(53.9, 27.56667);
  GoogleMapController mapController;

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
        if (!snapshot.hasData) {
          return Container();
        }

        return GoogleMap(
          initialCameraPosition: const CameraPosition(target: blr, zoom: 9),
          myLocationButtonEnabled: false,
          onMapCreated: (controller) => mapController = controller,
          markers: snapshot.data,
        );
      },
    );
  }
}

//class MarkerInfo {
//  final Marker marker;
//  final ImageStreamListener listener;
//  MarkerInfo()
//}

class MarkerCreator implements Disposable {
  final Set<Marker> _markers = {};
  final Map<Place, Marker> _placeMarker = {};
  //final Map<ImageStreamCompleter, ImageStreamListener> _imageStreams = {};
  final BehaviorSubject<Set<Marker>> _markersSubject =
      BehaviorSubject.seeded({});
  ui.Image _placeholder;

  MarkerCreator() {
    _loadPlaceholder();
  }

  Observable<Set<Marker>> get markers => _markersSubject;

  createMarkers(List<Place> places) {
    _refreshMarkers(places);
  }

  Future<Function()> _loadPlaceholder() async {
    ImageProvider provider = AssetImage('images/placeholder.png');
    var load = provider.load(await provider.obtainKey(ImageConfiguration()));
    var listener = ImageStreamListener((info, _) => _placeholder = info.image);
    load.addListener(listener);
    return () => load.removeListener(listener);
  }

  Future<Function()> _loadImage(String url, Function(ui.Image) func) async {
    ImageProvider provider = CachedNetworkImageProvider(url);
    var load = provider.load(await provider.obtainKey(ImageConfiguration()));
    var listener = ImageStreamListener((info, _) => func(info.image));
    load.addListener(listener);
    return () => load.removeListener(listener);
  }

  _loadImageAndCreateMarker(Place place) async {
    await _addMarkerToList(place, _placeholder);
    if (place.imageUrl != null) {
      var remover = await _loadImage(
          place.imageUrl, (image) => _addMarkerToList(place, image));
    }
  }

  _addMarkerToList(Place place, ui.Image image) async {
    final Uint8List markerIcon = await _createMarker(120, image);
    var marker = Marker(
        markerId: MarkerId(place.name),
        infoWindow: InfoWindow(title: place.name, snippet: place.about),
        position: LatLng(place.lat, place.lng),
        icon: BitmapDescriptor.fromBytes(markerIcon));

    _addMarker(place, marker);
  }

  _addMarker(Place place, Marker marker) {
    _removeMarker(place);
    _placeMarker[place] = marker;
    _markers.add(marker);
    _markersSubject.add(_markers);
  }

  _refreshMarkers(List<Place> places) {
    var toLoad = places.where((p) => !_placeMarker.keys.contains(p));
    var toDelete = _placeMarker.keys.where((p) => !places.contains(p));
    toDelete.forEach(_removeMarker);
    _markersSubject.add(_markers);
    toLoad.forEach(_loadImageAndCreateMarker);
  }

  _removeMarker(Place place) {
    if (_placeMarker[place] != null) {
      _markers.remove(_placeMarker[place]);
      _placeMarker.remove(place);
    }
  }

  Future<Uint8List> _createMarker(int height, ui.Image image) async {
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
    // TODO: implement dispose
  }
}
