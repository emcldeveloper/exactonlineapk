import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  final Map<String, String> data;
  final bool isActive;
  final VoidCallback onTap;

  const SubscriptionCard({
    super.key,
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      ParagraphText(
                        data["type"]!,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      if (data["priority"] != null &&
                          data["priority"]!
                              .isNotEmpty) // Check for non-empty priority
                        Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: ParagraphText(data["priority"]!,
                              fontSize: 10.0, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                ParagraphText(
                  data["discount"]!,
                  color: isActive ? Colors.white : Colors.black,
                  decoration: TextDecoration.lineThrough,
                ),
              ],
            ),
            spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ParagraphText(
                    '.save ${data["promotion"]!}',
                    color: isActive ? Colors.white : Colors.black,
                  ),
                ),
                ParagraphText(
                  data["price"]!,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.black,
                )
              ],
            ),
            spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Get ',
                          style: TextStyle(
                              color: isActive ? Colors.white : Colors.black),
                        ),
                        TextSpan(
                          text: data["trial period"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: ' free',
                          style: TextStyle(
                              color: isActive ? Colors.white : Colors.black),
                        ),
                      ],
                      style: TextStyle(
                          color: isActive ? Colors.white : Colors.black),
                    ),
                  ),
                ),
                ParagraphText(
                  data["duration"]!,
                  color: isActive ? Colors.white : Colors.black,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
