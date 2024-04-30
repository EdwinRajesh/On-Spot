// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../utils/colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userMessage = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  static const apiKey = 'AIzaSyA8FHucgMMgJUxMTdqFq7m_Bxcbmb5bbgU';

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = _userMessage.text;
    _userMessage.clear();
    isLoading;

    setState(() {
      _messages.add(Message(isUser: true, message: message));
      _isLoading = true;
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _messages.add(Message(isUser: false, message: response.text ?? " "));
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text('MechBot',
            style: TextStyle(
                color: Color(0xFF222831), fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Messages(
                  isLoading: isLoading,
                  isUser: message.isUser,
                  message: message.message,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 15,
                  child: TextFormField(
                    style: TextStyle(color: secondaryColor, fontSize: 18),
                    cursorColor: primaryColor,
                    controller: _userMessage,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: primaryColor)),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      hintText: 'Message ChatBot...',
                      suffixIcon: isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 16,
                                width: 8,
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                  strokeWidth: 4,
                                  // Adjust the thickness as needed
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(
                    width: 10), // Spacer between message box and send button
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF222831),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(8),
                    iconSize: 24,
                    color: primaryColor,
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      sendMessage();
                      _scrollToBottom();
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final bool isLoading;

  const Messages(
      {super.key,
      required this.isUser,
      required this.message,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthorizationProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isUser
              ? CircleAvatar(
                  backgroundColor: primaryColor,
                  backgroundImage: NetworkImage(ap.userModel.profilePic),
                  radius: 10,
                )
              : Container(
                  width: 20, // Adjust width and height to control the size
                  height: 20,
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.android, // Replace with your desired icon
                    color: Colors.white, // Adjust icon color as needed
                    size: 12, // Adjust icon size as needed
                  ),
                ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            flex: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (isLoading && !isUser)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 8),
                //     child: SizedBox(
                //       width: 16,
                //       height: 16,
                //       child: CircularProgressIndicator(
                //         strokeWidth: 4,
                //         color:
                //             secondaryColor, // Adjust the thickness of the circle
                //         // Use the color animation
                //       ),
                //     ),
                //   ),
                if (isUser)
                  Text(
                    "YOU",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (!isUser)
                  Text(
                    "MECHBOT",
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  message,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;

  Message({
    required this.isUser,
    required this.message,
  });
}
