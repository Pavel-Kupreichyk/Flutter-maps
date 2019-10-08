import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_maps/src/models/place.dart';

class CustomListTile extends StatelessWidget {
  final Function() onLocationButtonPressed;
  final Function() onItemSelected;
  final Place _place;

  CustomListTile(this._place, {this.onLocationButtonPressed, this.onItemSelected});

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
                  padding: const EdgeInsets.fromLTRB(12.0, 2.0, 2.0, 0.0),
                  child: _buildInfoWidget(_place, Theme.of(context)),
                ),
              ),
              IconButton(
                icon: Icon(Icons.my_location),
                onPressed: () {
                  if (onLocationButtonPressed != null) {
                    onLocationButtonPressed();
                  }
                },
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
      imageUrl: imageUrl,
      fit: BoxFit.cover,
    );
  }

  Widget _buildInfoWidget(Place place, ThemeData theme) {
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
                  fontSize: 15,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                place.about ?? '',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.0,
                  color: theme.disabledColor,
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
              Text(
                '★ ${place.userName ?? ''}',
                style: TextStyle(
                  fontSize: 12.0,
                  color: theme.disabledColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
