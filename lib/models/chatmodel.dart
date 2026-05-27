import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String text;
  final bool isMe;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.isMe,
    required this.createdAt,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessageModel(
      id: docId,
      text: map['text'] ?? '',
      isMe: map['isMe'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'text': text, 'isMe': isMe, 'createdAt': Timestamp.now()};
  }
}
