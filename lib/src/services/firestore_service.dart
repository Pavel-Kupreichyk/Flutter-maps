import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  static const String placesCollectionKey = 'places';
  static const String placeNameKey = 'name';
  static const String aboutKey = 'about';
  static const String placeLatKey = 'lat';
  static const String placeLngKey = 'lng';
  static const String imageKey = 'image';

  addNewPlace(String name, String about, File img, double lat, double lng) async {
    StorageTaskSnapshot url;
    if (img != null) {
      url = await _putPlaceImage(name, img);
    }

    await Firestore.instance
        .collection(placesCollectionKey)
        .document(name)
        .setData({
      placeNameKey: name,
      aboutKey: about,
      placeLatKey: lat,
      placeLngKey: lng,
      imageKey: url.ref.path
    });
  }

  Future<List<Place>> fetchPlaces() async {
    var snapshot = await Firestore.instance
        .collection(placesCollectionKey)
        .getDocuments();
    List<Place> result = [];

    if (snapshot != null) {
      for (var doc in snapshot.documents) {
        String imgUrl;
        if (doc[imageKey] != null) {
          imgUrl = await _getImageUrl(doc[imageKey]);
        }
        result.add(Place(
            doc[placeNameKey], imgUrl, doc[aboutKey], doc[placeLatKey], doc[placeLngKey]));
      }
    }

    return result;
  }

  Future<StorageTaskSnapshot> _putPlaceImage(String name, File image) async {
    final StorageReference storageRef =
        FirebaseStorage.instance.ref().child(name);
    final StorageUploadTask uploadTask = storageRef.putFile(
      image,
      //TODO: Add metadata
      //      StorageMetadata(
      //        contentType: type + '/' + extension,
      //      ),
    );
    return await uploadTask.onComplete;
  }

  Future<String> _getImageUrl(String name) async {
    final StorageReference storageRef =
        FirebaseStorage.instance.ref().child(name);
    return await storageRef.getDownloadURL();
  }
}
