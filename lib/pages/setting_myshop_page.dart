import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: ParagraphText(
          "Settings",
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            ParagraphText(
              "Current business",
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            spacer1(),
            // Change Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  // Handle Change Button Pressed
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: ParagraphText(
                  "Change",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            spacer1(),
            // Business Details
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeadingText(
                    "Vunja Bei shop",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  spacer(),
                  ParagraphText(
                    "Created at 20/05/2024",
                    fontSize: 14,
                    color: mutedTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
