import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
  final Map<dynamic, dynamic> message =
        Get.arguments as Map<dynamic, dynamic>? ?? {};
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(Icons.arrow_back_ios)),
        title: ParagraphText(message['name'] ?? 'Unknown'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ParagraphText(
            message['message'] ?? 'No message available.',
          ),
        ],
      ),
    );
  }
}
