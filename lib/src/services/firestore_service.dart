import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_maps/src/models/place.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

abstract class PlaceCollection {
  static const String key = 'places';
  static const String userId = 'userId';
  static const String username = 'username';
  static const String name = 'name';
  static const String about = 'about';
  static const String lat = 'lat';
  static const String lng = 'lng';
}

abstract class UserCollection {
  static const String key = 'users';
  static const String userId = 'userId';
  static const String username = 'username';
}

class FirestoreService {
  Future<StorageUploadTask> addNewPlace(String userId, String name,
      String about, File img, double lat, double lng) async {
    var user = await Firestore.instance
        .collection(UserCollection.key)
        .document(userId)
        .get();
    await Firestore.instance
        .collection(PlaceCollection.key)
        .document('${userId}_$name')
        .setData({
      PlaceCollection.userId: userId,
      PlaceCollection.username: user[UserCollection.username],
      PlaceCollection.name: name,
      PlaceCollection.about: about,
      PlaceCollection.lat: lat,
      PlaceCollection.lng: lng
    });

    if (img != null) {
      return await _uploadPlaceImage('${userId}_$name', img);
    }
    return null;
  }

  Future<bool> checkUsername(String username) async {
    var res = await Firestore.instance
        .collection(UserCollection.key)
        .where(UserCollection.username, isEqualTo: username)
        .getDocuments();

    return res.documents.isEmpty;
  }

  addNewUser(String userId, String username) async {
    await Firestore.instance
        .collection(UserCollection.key)
        .document(userId)
        .setData({
      UserCollection.userId: userId,
      UserCollection.username: username,
    });
  }

  Future<List<Place>> fetchPlaces() async {
    var snapshot =
        await Firestore.instance.collection(PlaceCollection.key).getDocuments();
    List<Place> result = [];
    if (snapshot != null) {
      for (var doc in snapshot.documents) {
        result.add(Place(
            doc[PlaceCollection.userId],
            doc[PlaceCollection.username],
            doc[PlaceCollection.name],
            await _getImageUrl('${doc[PlaceCollection.userId]}_${doc[PlaceCollection.name]}'),
            doc[PlaceCollection.about],
            doc[PlaceCollection.lat],
            doc[PlaceCollection.lng]));
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
