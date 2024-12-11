import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class ReportSellerBottomSheet extends StatelessWidget {
  const ReportSellerBottomSheet({super.key});

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ParagraphText(
                        "Report this seller",
                        fontWeight: FontWeight.bold,
                      ),
                      ParagraphText("Reasons for reporting this seller",
                          color: mutedTextColor),
                    ],
                  ),
                ),
              ],
            ),
            spacer1(),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              decoration: InputDecoration(
                fillColor: primaryColor,
                filled: true,
                labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: primaryColor,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                hintText: "Write reasons for reporting this seller",
                hintStyle: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            spacer1(),
            customButton(
              onTap: () {},
              text: "Submit Report",
            ),
            spacer2(),
          ],
        ),
      ),
    );
  }
}
