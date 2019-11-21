import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

abstract class _PlaceCollection {
  static const String key = 'places';
  static const String userId = 'userId';
  static const String username = 'username';
  static const String name = 'name';
  static const String about = 'about';
  static const String lat = 'lat';
  static const String lng = 'lng';
}

abstract class _UserCollection {
  static const String key = 'users';
  static const String userId = 'userId';
  static const String username = 'username';
}

class FirestoreService {

  Future<StorageUploadTask> addNewPlace(String userId, String name,
      String about, File img, double lat, double lng) async {
    var user = await Firestore.instance
        .collection(_UserCollection.key)
        .document(userId)
        .get();
    await Firestore.instance
        .collection(_PlaceCollection.key)
        .document('${userId}_$name')
        .setData({
      _PlaceCollection.userId: userId,
      _PlaceCollection.username: user[_UserCollection.username],
      _PlaceCollection.name: name,
      _PlaceCollection.about: about,
      _PlaceCollection.lat: lat,
      _PlaceCollection.lng: lng
    });

    if (img != null) {
      return await _uploadPlaceImage('${userId}_$name', img);
    }
    return null;
  }

  Future<bool> checkUsername(String username) async {
    var res = await Firestore.instance
        .collection(_UserCollection.key)
        .where(_UserCollection.username, isEqualTo: username)
        .getDocuments();

    return res.documents.isEmpty;
  }

  addNewUser(String userId, String username) async {
    await Firestore.instance
        .collection(_UserCollection.key)
        .document(userId)
        .setData({
      _UserCollection.userId: userId,
      _UserCollection.username: username,
    });
  }

  Future<List<Place>> fetchPlaces() async {
    var snapshot =
        await Firestore.instance.collection(_PlaceCollection.key).getDocuments();
    List<Place> result = [];
    if (snapshot != null) {
      for (var doc in snapshot.documents) {
        result.add(Place(
            doc[_PlaceCollection.userId],
            doc[_PlaceCollection.username],
            doc[_PlaceCollection.name],
            await _getImageUrl(
                '${doc[_PlaceCollection.userId]}_${doc[_PlaceCollection.name]}'),
            doc[_PlaceCollection.about],
            doc[_PlaceCollection.lat],
            doc[_PlaceCollection.lng]));
      }
    }
    return result;
  }

  Future<StorageUploadTask> _uploadPlaceImage(String name, File image) async {
    final StorageReference storageRef =
        FirebaseStorage.instance.ref().child(name);
    return storageRef.putFile(image);
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
