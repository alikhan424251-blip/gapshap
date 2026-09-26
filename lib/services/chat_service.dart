import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Chat room ID (dono users ke UID sort kar ke)
  String chatRoomId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  // Message bhejein
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String text,
    String type = 'text', // text, image, video
    String mediaUrl = '',
  }) async {
    final msg = {
      'senderId': senderId,
      'text': text,
      'type': type,
      'mediaUrl': mediaUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };
    await _db
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(msg);

    // Chat room ka last message update karein
    await _db.collection('chats').doc(chatRoomId).set({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participants': chatRoomId.split('_'),
    }, SetOptions(merge: true));
  }

  // Messages ka real-time stream
  Stream<QuerySnapshot> messagesStream(String chatRoomId) {
    return _db
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // User ki chat list
  Stream<QuerySnapshot> chatListStream(String uid) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Photo/video upload karein
  Future<String> uploadMedia(File file, String chatRoomId) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}';
    final ref = _storage.ref().child('chats/$chatRoomId/$name');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // Group banayein
  Future<String> createGroup({
    required String name,
    required String createdBy,
    required List<String> memberIds,
  }) async {
    final doc = await _db.collection('groups').add({
      'name': name,
      'createdBy': createdBy,
      'members': memberIds,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Group message bhejein
  Future<void> sendGroupMessage({
    required String groupId,
    required String senderId,
    required String text,
    String type = 'text',
    String mediaUrl = '',
  }) async {
    await _db.collection('groups').doc(groupId).collection('messages').add({
      'senderId': senderId,
      'text': text,
      'type': type,
      'mediaUrl': mediaUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _db.collection('groups').doc(groupId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> groupMessagesStream(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
