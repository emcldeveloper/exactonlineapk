import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class ShopSubscriptionCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ShopSubscriptionCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
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
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      if (data["hint"] != null &&
                          data["hint"]!.trim().isNotEmpty)
                        Container(
                          width: 110,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange, Colors.amber],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: ParagraphText(
                            data["hint"]!,
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  spacer(),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '. ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: data["freeDays"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: ' Days remained ',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ParagraphText("Paid",
                    color: Colors.white,
                    decoration: TextDecoration.lineThrough,
                    textAlign: TextAlign.center),
                ParagraphText(
                  "TZS ${data["price"]}",
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'at',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: data["freeDays"]!,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: ' at 12, Sept 2024 ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    // textAlign: TextAlign.center
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
