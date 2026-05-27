import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String location;
  final String bio;
  final String imageUrl;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.location,
    required this.bio,
    required this.imageUrl,
    this.createdAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      bio: map['bio'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'location': location,
      'bio': bio,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
