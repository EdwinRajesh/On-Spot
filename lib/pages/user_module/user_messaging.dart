import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../providers/chat_services.dart';
import '../../utils/chat_bubble.dart';
//import '../../utils/chat_tile.dart';
import '../../utils/colors.dart';

// Import the PaymentPage
import 'payment_page.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;
  final String profilePic;

  ChatPage(
      {Key? key,
      required this.receiverEmail,
      required this.receiverID,
      required this.profilePic, required receiverName})
      : super(key: key);

  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(receiverID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tertiaryColor,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              backgroundImage: NetworkImage(profilePic),
              radius: 22,
            ),
            SizedBox(
              width: 8,
            ),
            Text(receiverEmail),
          ],
        ),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(context), // Pass context here
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = auth.currentUser!.phoneNumber!;
    return StreamBuilder(
      stream: _chatService.getMessages(receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        if (!snapshot.hasData) {
          return const Text("No data");
        }
        return ListView(
          children: (snapshot.data! as QuerySnapshot)
              .docs
              .map((doc) => _buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == auth.currentUser!.phoneNumber;

    var alignment =
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Container(
      child: Column(
        crossAxisAlignment: alignment, // Use CrossAxisAlignment here
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
            timestamp: DateTime.now(),
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput(BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 16,
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Message",
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00A8A8),
                ),
                child: IconButton(
                  iconSize: 24,
                  color: Colors.white,
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: IconButton(
          iconSize: 24,
          color: Colors.white,
          icon: Icon(Icons.payment),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PaymentPage()),
            );
          },
        ),
      ),
    ],
  );
}
}