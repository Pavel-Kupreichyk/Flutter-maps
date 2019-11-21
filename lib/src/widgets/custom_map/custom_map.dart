import 'package:flutter/material.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:flutter_maps/src/widgets/custom_map/marker_creator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_maps/src/support/bindable_state.dart';

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

class _CustomMapState extends BindableState<CustomMap> {
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
