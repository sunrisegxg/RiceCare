import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/usermodel.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 CREATE USER
  Future<void> createUser(String userId, UserModel user) async {
    try {
      log("CREATE FIRESTORE USER: $userId");

      final docRef = _firestore.collection('users').doc(userId);

      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set(user.toMap());

        log("CREATE SUCCESS");
      } else {
        log("USER ALREADY EXISTS");
      }
    } catch (e) {
      log("CREATE ERROR: $e");
    }
  }

  /// 🔹 GET USER
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      return UserModel.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception("Get user failed: $e");
    }
  }

  /// 🔹 UPDATE USER
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception("Update user failed: $e");
    }
  }

  /// 🔹 DELETE USER
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception("Delete user failed: $e");
    }
  }
}
