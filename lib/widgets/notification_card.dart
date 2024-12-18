import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const NotificationCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 33,
                  height: 33,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedNotification01,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: ParagraphText(data['message'] ?? "N/A",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 15.0),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
          ),
          ParagraphText(
            data['time'] ?? "N/A",
            color: mutedTextColor,
          ),
        ],
      ),
    );
  }
}
