import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';

class CommingSoon extends StatelessWidget {
  const CommingSoon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          // Top bar indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 228, 228, 228),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spacer1(),
                  Image.asset(
                    'assets/images/closeicon.jpg',
                    height: 100,
                  ),
                  spacer1(),
                  HeadingText('Coming soon'),
                  spacer(),
                  ParagraphText(
                    'This feature is coming soon',
                    color: mutedTextColor,
                  ),
                  spacer3(),
                  customButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    text: "OK",
                    rounded: 15.0,
                  ),
                  spacer1(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
