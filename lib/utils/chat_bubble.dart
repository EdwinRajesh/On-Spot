// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'colors.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime timestamp; // Add timestamp property

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp, // Initialize timestamp
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment:
                CrossAxisAlignment.end, // Align the timestamp to the bottom
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isCurrentUser ? primaryColor : secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        color: isCurrentUser ? secondaryColor : Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('HH:mm').format(timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              )
            ],
          ),
        ),
      ],
    );
  }
}
