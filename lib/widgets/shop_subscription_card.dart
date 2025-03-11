import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShopSubscriptionCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ShopSubscriptionCard({
    super.key,
    required this.data,
  });

  int getDaysRemaining() {
    DateTime expireDate = DateTime.parse(data["expireDate"]);
    DateTime now = DateTime.now();
    return expireDate.difference(now).inDays;
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    int daysRemaining = getDaysRemaining();
    String createdAtFormatted = formatDate(data["createdAt"]);

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
                        data['Subscription']["title"]!,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      if (data['Subscription']["hint"] != null &&
                          data['Subscription']["hint"]!.trim().isNotEmpty)
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
                              data['Subscription']["hint"]!,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  spacer(),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '. ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: "$daysRemaining",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const TextSpan(
                          text: ' Days remained ',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                      style: const TextStyle(color: Colors.white),
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
                  "TZS ${data['Subscription']["price"]}",
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'at ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: createdAtFormatted,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
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
