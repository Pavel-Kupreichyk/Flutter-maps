import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/place_info_bloc.dart';
import 'package:flutter_maps/src/widgets/custom_map/custom_map.dart';

class PlaceInfoScreenBody extends StatefulWidget {
  final PlaceInfoBloc bloc;
  PlaceInfoScreenBody(this.bloc);

  @override
  _PlaceInfoScreenBodyState createState() => _PlaceInfoScreenBodyState();
}

class _PlaceInfoScreenBodyState extends State<PlaceInfoScreenBody> {
  @override
  Widget build(BuildContext context) {
    final place = widget.bloc.place;
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          title: Text(place.name),
          expandedHeight: place.imageUrl != null ? 200.0 : 0,
          flexibleSpace: place.imageUrl != null
              ? FlexibleSpaceBar(
                  background: _buildImageWidget(place.imageUrl),
                )
              : null,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _CustomText('About'),
                    _CustomText(place.about, fontSize: 16, isBold: false),
                    const _CustomText('Location'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 8),
                height: 250,
                child: CustomMap(
                    places: [widget.bloc.place],
                    startLocation: widget.bloc.placeLocation,
                    startZoom: 15,
                    gesturesEnabled: false),
              ),
              SafeArea(
                  top: false,
                  bottom: false,
                  child: _CustomText('Author: ${place.userName}',
                      fontSize: 18, isBold: true)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl == null) {
      return Image.asset('images/placeholder.png', fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      placeholder: (context, url) => Container(
          child: const Center(child: CircularProgressIndicator()), width: 100),
      imageUrl: imageUrl,
      fit: BoxFit.cover,
    );
  }
}

class _CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool isBold;

  const _CustomText(this.text, {this.fontSize = 25, this.isBold = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8),
      child: Text(
        text,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}
