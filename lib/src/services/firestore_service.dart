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

  Future<StorageUploadTask> addNewPlace(String name, String about, File img, double lat, double lng) async {
    await Firestore.instance
        .collection(placesCollectionKey)
        .document(name)
        .setData({
      placeNameKey: name,
      aboutKey: about,
      placeLatKey: lat,
      placeLngKey: lng
    });

    if (img != null) {
      return await _uploadPlaceImage(name, img);
    }
    return null;
  }

  Future<List<Place>> fetchPlaces() async {
    var snapshot = await Firestore.instance
        .collection(placesCollectionKey)
        .getDocuments();
    List<Place> result = [];

    if (snapshot != null) {
      for (var doc in snapshot.documents) {
        String imgUrl = await _getImageUrl(doc[placeNameKey]);

        result.add(Place(
            doc[placeNameKey], imgUrl, doc[aboutKey], doc[placeLatKey], doc[placeLngKey]));
      }
    }

    return result;
  }

  Future<StorageUploadTask> _uploadPlaceImage(String name, File image) async {
    final StorageReference storageRef =
        FirebaseStorage.instance.ref().child(name);
    return storageRef.putFile(
      image,
      //TODO: Add metadata
    );
  }

  Future<String> _getImageUrl(String name) async {
    final StorageReference storageRef =
        FirebaseStorage.instance.ref().child(name);
    
    try {
      return await storageRef.getDownloadURL();
    } catch (err) {
      return null;
    }
  }
}
