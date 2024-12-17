import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';

class BlockingReel extends StatelessWidget {
  const BlockingReel({super.key});

  final List<Map<String, String>> _stats = const [
    {"text": "Problem involving someone under 18"},
    {"text": "Bullying, harassment or abuse"},
    {"text": "Violent, hateful or disturbing content"},
    {"text": "Selling or promoting restricted items"},
    {"text": "Adult content"},
    {"text": "Scam, fraud or false information"},
    {"text": "I don`t want to see this"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            spacer1(),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: mutedTextColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            spacer1(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ParagraphText(
                        "Why are you blocking this post?",
                        fontWeight: FontWeight.bold,
                      ),
                      ParagraphText(
                        "Select the reasons why you want to block this post",
                        color: mutedTextColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            spacer2(),
            // Dynamic list of rows
            ..._stats.map((stat) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ParagraphText(
                      stat['text'] ?? "",
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: mutedTextColor,
                      size: 16.0,
                    ),
                  ],
                ),
              );
            }),
            spacer1(),
          ],
        ),
      ),
    );
  }
}
