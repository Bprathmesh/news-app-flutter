import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AppUser? _user;
  bool _isLoading = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = result.user;
      if (firebaseUser != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          _user = AppUser.fromDocument(doc);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print(e.toString());
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = result.user;
      if (firebaseUser != null) {
        _user = AppUser(
          id: firebaseUser.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(_user!.toMap());
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e.toString());
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _user = AppUser.fromDocument(doc);
        notifyListeners();
      }
    }
  }
}