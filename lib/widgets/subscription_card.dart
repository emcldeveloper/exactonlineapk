import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  final Map<String, dynamic> data;
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ParagraphText(
                        data["title"]!,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      if (data["hint"] != null &&
                          data["hint"]!.trim().isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Colors.amber],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 2.0),
                            child: ParagraphText(
                              data["hint"]!,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  spacer(),
                  ParagraphText(
                    '.save ${data["percentSaved"]!}%',
                    color: isActive ? Colors.white : Colors.black,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Get ',
                        ),
                        TextSpan(
                          text: '${data["freeDays"]!} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: 'days free',
                        ),
                      ],
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ParagraphText(
                  "TZS ${data["originalPrice"]}",
                  color: isActive ? Colors.white : Colors.black,
                  decoration: TextDecoration.lineThrough,
                  textAlign: TextAlign.center,
                ),
                ParagraphText(
                  "TZS ${data["price"]}",
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: isActive ? Colors.white : Colors.black,
                  textAlign: TextAlign.center,
                ),
                ParagraphText(
                  data["duration"]!,
                  color: isActive ? Colors.white : Colors.black,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
