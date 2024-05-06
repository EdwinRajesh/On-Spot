// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../providers/chat_services.dart';
import '../../utils/chat_bubble.dart';
import '../../utils/chat_tile.dart';
import '../../utils/colors.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;
  final String profilePic;
  final String receiverName;

  ChatPage(
      {super.key,
      required this.receiverEmail,
      required this.receiverID,
      required this.profilePic,
      required this.receiverName});

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
            Text(receiverName),
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
          _buildUserInput(),
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
          children: (snapshot.data!)
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
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              message: data["message"],
              isCurrentUser: isCurrentUser,
              timestamp: DateTime.now(),
            ),
            SizedBox(
              height: 8,
            )
            //Text(data['message']),
          ],
        ));
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 16,
            child: MyTextField(
              controller: _messageController,
              hintText: "Message",
              obscureText: false,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF00A8A8),
            ),
            child: IconButton(
              iconSize: 24,
              color: secondaryColor,
              icon: const Icon(Icons.send),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
