import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';
import 'phone_auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _chat = ChatService();

  void _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
        (_) => false,
      );
    }
  }

  // Nayi chat shuru karein (phone number se user dhoondein)
  void _newChat() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nayi chat'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Dost ka phone number',
            hintText: '+923001234567',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final phone = controller.text.trim();
              if (phone.isEmpty) return;
              Navigator.pop(context);
              // Phone se user dhoondein
              final snap = await FirebaseFirestore.instance
                  .collection('users')
                  .where('phone', isEqualTo: phone)
                  .limit(1)
                  .get();
              if (snap.docs.isEmpty && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ye number GapShap pe nahi mila')));
                return;
              }
              final other = snap.docs.first;
              final myUid = _auth.currentUser!.uid;
              if (other.id == myUid) return;
              final roomId = _chat.chatRoomId(myUid, other.id);
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatRoomId: roomId,
                      otherName: (other.data()['name'] as String).isEmpty
                          ? (other.data()['phone'] ?? 'Chat')
                          : other.data()['name'],
                    ),
                  ),
                );
              }
            },
            child: const Text('Chat karein'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myUid = _auth.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('GapShap'),
        backgroundColor: const Color(0xFF0B8A5F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout), tooltip: 'Logout'),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chat.chatListStream(myUid),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Chat list mein masla:\n${snap.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          // Nayi chat sab se upar (client side sort, koi index nahi chahiye)
          final docs = snap.data!.docs.toList()
            ..sort((a, b) {
              final da = a.data() as Map<String, dynamic>;
              final db = b.data() as Map<String, dynamic>;
              final ta = da['lastMessageTime'];
              final tb = db['lastMessageTime'];
              final dta =
                  ta is Timestamp ? ta.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
              final dtb =
                  tb is Timestamp ? tb.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
              return dtb.compareTo(dta);
            });
          if (docs.isEmpty) {
            return const Center(
              child: Text('Abhi koi chat nahi\nNeeche + dabayein',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF0B8A5F),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text('Chat'),
                subtitle: Text(data['lastMessage'] ?? '',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatRoomId: docs[i].id,
                      otherName: 'Chat',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newChat,
        backgroundColor: const Color(0xFF0B8A5F),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
