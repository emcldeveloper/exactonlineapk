import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final Map<String, dynamic> chatData =
      Get.arguments as Map<String, dynamic>? ?? {};
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
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: mutedTextColor,
            size: 16.0,
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  AssetImage(chatData['avatar'] ?? 'assets/images/avatar.png'),
            ),
            const SizedBox(width: 8),
            HeadingText(chatData['name'] ?? 'Unknown'),
          ],
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: primaryColor,
            height: 1.0,
          ),
        ),
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
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: primaryColor, width: 1.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        fillColor: primaryColor,
                        filled: true,
                        hintText: "Write your message here",
                        hintStyle: const TextStyle(fontSize: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryColor,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30.0)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  InkWell(
                      onTap: _sendMessage,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Transform.rotate(
                              angle: 6.3,
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedSent,
                                color: Colors.white,
                                size: 24.0,
                              ),
                            ),
                          ))),
                ],
              ),
            ),
          ),
          spacer1(),
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
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
