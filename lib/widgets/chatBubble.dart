import 'package:e_online/constants/colors.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final String text;
  final bool isSentByMe;
  final String time;

  ChatBubble(
      {required this.message,
      required this.text,
      required this.isSentByMe,
      required this.time,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (isSentByMe)
                Icon(
                  Icons.done_all,
                  size: 16,
                  color: message["delivered"] ? Colors.green : Colors.grey,
                ),
              SizedBox(
                width: 5,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isSentByMe ? primary.withOpacity(0.4) : Colors.grey[100],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(isSentByMe ? 12 : 0),
                    bottomRight: Radius.circular(isSentByMe ? 0 : 12),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}
