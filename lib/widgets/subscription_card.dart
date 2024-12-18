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
                        data["type"]!,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      if (data["priority"] != null &&
                          data["priority"]!
                              .isNotEmpty) // Check for non-empty priority
                        Container(
                          width: 110,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange,
                                Colors.amber
                              ], // Define gradient colors
                              begin: Alignment
                                  .centerLeft, // Start from the left center
                              end: Alignment
                                  .centerRight, // End at the right center
                            ),
                            borderRadius:
                                BorderRadius.circular(10), // Rounded edges
                          ),
                          alignment: Alignment.center,
                          child: ParagraphText(
                            data["priority"]!,
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  spacer(),
                  ParagraphText(
                    '.save ${data["promotion"]!}',
                    color: isActive ? Colors.white : Colors.black,
                  ),
                  RichText(
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
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ParagraphText(data["discount"]!,
                    color: isActive ? Colors.white : Colors.black,
                    decoration: TextDecoration.lineThrough,
                    textAlign: TextAlign.center),
                ParagraphText(
                  data["price"]!,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: isActive ? Colors.white : Colors.black,
                  textAlign: TextAlign.center,
                ),
                ParagraphText(data["duration"]!,
                    color: isActive ? Colors.white : Colors.black,
                    textAlign: TextAlign.center),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
