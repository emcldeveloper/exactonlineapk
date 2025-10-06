import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const NotificationCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    bool isRead = data['isRead'] ?? true;

    return Container(
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(isRead ? 0 : 8),
        child: InkWell(
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
                        color: isRead
                            ? Colors.grey[100]
                            : primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedNotification01,
                        color: isRead ? Colors.grey : primary,
                        size: 22.0,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ParagraphText(
                            data['title'] ?? data['message'] ?? "N/A",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 15.0,
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.w600,
                          ),
                          if (data['title'] != null && data['message'] != null)
                            ParagraphText(
                              data['message'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 13.0,
                              color: mutedTextColor,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ParagraphText(
                    data['time'] ?? "N/A",
                    color: mutedTextColor,
                    fontSize: 12.0,
                  ),
                  if (!isRead) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
