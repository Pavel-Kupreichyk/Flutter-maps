import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_maps/src/models/place.dart';

class CustomListTile extends StatelessWidget {
  final Function onItemSelected;
  final Place _place;

  CustomListTile(this._place, {this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: InkWell(
        child: SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: const Radius.circular(4),
                      bottomLeft: const Radius.circular(4)),
                  child: _buildImageWidget(_place.imageUrl),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 2.0, 2.0, 0.0),
                  child: _buildInfoWidget(_place),
                ),
              )
            ],
          ),
        ),
        onTap: () {
          if (onItemSelected != null) {
            onItemSelected();
          }
        },
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl == null) {
      return Image.asset('images/placeholder.png', fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      placeholder: (context, url) => Container(
          child: const Center(child: CircularProgressIndicator()), width: 100),
      imageUrl: imageUrl,//'https://image.tmdb.org/t/p/original/kqjL17yufvn9OVLyXYpvtyrFfak.jpg', //<- For tests
      fit: BoxFit.cover,
    );
  }

  Widget _buildInfoWidget(Place place) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                place.name ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                place.about ?? '',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              const Text(
                ' · ★',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
