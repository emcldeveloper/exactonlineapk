import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';

class ActiveBusinessSelection extends StatelessWidget {
  const ActiveBusinessSelection({super.key});

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
            ParagraphText(
              "Select business",
              fontWeight: FontWeight.bold,
            ),
            spacer2(),

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
               customButton(
                onTap: () {},
                text: "Save selection",
              ),
              spacer3(),
          ],
        ),
      ),
    );
  }
}
