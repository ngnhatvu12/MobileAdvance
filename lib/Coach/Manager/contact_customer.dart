import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoachMessengerPage extends StatefulWidget {
  final String customerId;
  final String coachId;
  final String studentId;
  final String studentName;
  final String studentImageUrl;

  const CoachMessengerPage({
    Key? key,
    required this.customerId,
    required this.coachId,
    required this.studentId,
    required this.studentName,
    required this.studentImageUrl,
  }) : super(key: key);

  @override
  _CoachMessengerPageState createState() => _CoachMessengerPageState();
}

class _CoachMessengerPageState extends State<CoachMessengerPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _contactDocId;

  @override
  void initState() {
    super.initState();
    _findContactDocument();
  }

  Future<void> _findContactDocument() async {
    // Tìm document contact có coachId trùng với coachId hiện tại
    final querySnapshot = await _firestore
        .collection('users')
        .doc(widget.studentId)
        .collection('contacts')
        .where('coachId', isEqualTo: widget.coachId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _contactDocId = querySnapshot.docs.first.id;
      });
    }
  }

  Future<void> _sendMessage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Nếu chưa có document contact thì tạo mới
    if (_contactDocId == null) {
      final newContactDoc = await _firestore
          .collection('users')
          .doc(widget.studentId)
          .collection('contacts')
          .add({
            'coachId': widget.coachId,
            'name': widget.studentName,
            'imageUrl': widget.studentImageUrl,
            'lastMessage': message,
            'timestamp': FieldValue.serverTimestamp(),
          });

      setState(() {
        _contactDocId = newContactDoc.id;
      });
    }

    // Thêm tin nhắn vào subcollection messages
    await _firestore
        .collection('users')
        .doc(widget.studentId)
        .collection('contacts')
        .doc(_contactDocId)
        .collection('messages')
        .add({
          'text': message,
          'senderId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

    // Cập nhật lastMessage trong document contact
    await _firestore
        .collection('users')
        .doc(widget.studentId)
        .collection('contacts')
        .doc(_contactDocId)
        .update({
          'lastMessage': message,
          'timestamp': FieldValue.serverTimestamp(),
        });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.studentImageUrl),
            ),
            const SizedBox(width: 10),
            Text(widget.studentName, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            child: _contactDocId == null
                ? const Center(child: Text('Chưa có tin nhắn nào'))
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .doc(widget.studentId)
                        .collection('contacts')
                        .doc(_contactDocId)
                        .collection('messages')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('Chưa có tin nhắn nào'));
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index].data() as Map<String, dynamic>;
                          final isMe = message['senderId'] == user?.uid;
                          final timestamp = message['timestamp'] != null 
                                  ? (message['timestamp'] as Timestamp).toDate()
                                  : DateTime.now();
                                  
                          final timeString = '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

                          if (isMe) {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      message['text'],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeString,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(widget.studentImageUrl),
                                  radius: 15,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message['text'],
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        timeString,
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () => _showFileOptions(context),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _showFileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.red),
                title: const Text('Gửi bài tập'),
                onTap: () {
                  Navigator.pop(context);
                  // Xử lý gửi bài tập
                },
              ),
              ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.green),
                title: const Text('Gửi thực đơn'),
                onTap: () {
                  Navigator.pop(context);
                  // Xử lý gửi thực đơn
                },
              ),
              ListTile(
                leading: const Icon(Icons.assessment, color: Colors.blue),
                title: const Text('Gửi báo cáo'),
                onTap: () {
                  Navigator.pop(context);
                  // Xử lý gửi báo cáo
                },
              ),
            ],
          ),
        );
      },
    );
  }

}