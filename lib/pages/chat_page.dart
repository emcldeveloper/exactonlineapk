import 'package:e_online/widgets/heading_text.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeadingText("Chat PAGE"),
        ],
      ),
    );
  }
}