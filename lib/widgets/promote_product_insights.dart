import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';

class PromoteProductInsightsBottomSheet extends StatelessWidget {
  const PromoteProductInsightsBottomSheet({super.key});

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
                        "Product promotion insights",
                        fontWeight: FontWeight.bold,
                      ),
                      ParagraphText(
                        "View product insights",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            spacer1(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ParagraphText(
                  "Impressions",
                  fontWeight: FontWeight.bold,
                ),
                ParagraphText("25,000", fontWeight: FontWeight.bold),
              ],
            ),
            spacer1(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ParagraphText(
                  "Clicks",
                  fontWeight: FontWeight.bold,
                ),
                ParagraphText("400", fontWeight: FontWeight.bold),
              ],
            ),
            spacer1(),
          ],
        ),
      ),
    );
  }
}
