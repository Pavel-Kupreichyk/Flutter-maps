import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    var result =  await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return result.user.uid;
  }

  Future<String> signUp(String email, String password) async {
    var result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user.uid;
  }

  Future<String> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user?.uid;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}