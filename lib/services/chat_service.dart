import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chatmodel.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Gửi tin nhắn
  Future<void> sendMessage(String userId, ChatMessageModel message) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .add(message.toMap());
    } catch (e) {
      throw Exception("Send message failed: $e");
    }
  }

  /// 🔹 Lấy chat realtime
  Stream<List<ChatMessageModel>> getMessages(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatMessageModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// 🔹 Lấy chat 1 lần
  Future<List<ChatMessageModel>> getMessagesOnce(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .orderBy('createdAt')
          .get();

      return snapshot.docs.map((doc) {
        return ChatMessageModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception("Get messages failed: $e");
    }
  }

  /// 🔹 Xoá 1 tin nhắn
  Future<void> deleteMessage(String userId, String messageId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception("Delete message failed: $e");
    }
  }

  /// 🔹 Xoá toàn bộ chat
  Future<void> deleteAllMessages(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception("Delete all messages failed: $e");
    }
  }
}
