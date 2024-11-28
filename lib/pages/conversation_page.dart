import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final Map<dynamic, dynamic> chatData =
      Get.arguments as Map<dynamic, dynamic>? ?? {};
  final List<String> messages = []; 
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      setState(() {
        messages.add(messageText);
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(chatData['avatar'] ?? 'assets/images/avatar.png'),
            ),
            SizedBox(width: 8),
            ParagraphText(chatData['name'] ?? 'Unknown'),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Display the initial message
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: ChatBubble(
                      text: chatData['message'] ?? 'No message available.',
                      isSentByMe: false,
                    ),
                  );
                }
                return Align(
                  alignment: Alignment.centerRight,
                  child: ChatBubble(
                    text: messages[index - 1],
                    isSentByMe: true,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSentByMe;

  const ChatBubble({required this.text, required this.isSentByMe, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSentByMe ? Colors.blue[100] : Colors.grey[300],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isSentByMe ? 12 : 0),
          bottomRight: Radius.circular(isSentByMe ? 0 : 12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
