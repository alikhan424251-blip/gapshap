import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherName;
  const ChatScreen({super.key, required this.chatRoomId, required this.otherName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();
  final _auth = AuthService();
  final _chat = ChatService();
  final _scroll = ScrollController();
  bool _sending = false;

  void _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _msgController.clear();
    await _chat.sendMessage(
      chatRoomId: widget.chatRoomId,
      senderId: _auth.currentUser!.uid,
      text: text,
    );
    setState(() => _sending = false);
    _scrollToBottom();
  }

  void _sendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _sending = true);
    final url = await _chat.uploadMedia(File(picked.path), widget.chatRoomId);
    await _chat.sendMessage(
      chatRoomId: widget.chatRoomId,
      senderId: _auth.currentUser!.uid,
      text: '📷 Photo',
      type: 'image',
      mediaUrl: url,
    );
    setState(() => _sending = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final myUid = _auth.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherName),
        backgroundColor: const Color(0xFF0B8A5F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chat.messagesStream(widget.chatRoomId),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final m = docs[i].data() as Map<String, dynamic>;
                    final mine = m['senderId'] == myUid;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: mine ? const Color(0xFF0B8A5F) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: m['type'] == 'image' && (m['mediaUrl'] as String).isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(m['mediaUrl'], fit: BoxFit.cover),
                              )
                            : Text(
                                m['text'] ?? '',
                                style: TextStyle(
                                    color: mine ? Colors.white : Colors.black87,
                                    fontSize: 15),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey[100],
            child: Row(
              children: [
                IconButton(onPressed: _sendImage, icon: const Icon(Icons.image)),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: 'Message likhein...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24))),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send, color: Color(0xFF0B8A5F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
