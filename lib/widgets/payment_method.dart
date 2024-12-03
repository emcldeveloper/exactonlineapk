import 'package:e_online/pages/promoted_product_view_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:get/get.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  const PaymentMethodBottomSheet({super.key});

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
                        "Pay with mobile money",
                        fontWeight: FontWeight.bold,
                      ),
                      ParagraphText(
                        "Enter your phone number to pay",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            spacer1(),
            TextFormField(
              keyboardType: TextInputType.text,
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
                hintText: "Write your phone number",
                hintStyle: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            spacer1(),
            customButton(
              onTap: () {
                // Example product data
                Map<String, dynamic> productData = {
                  "title": "Sample Product",
                  "price": "TZS 250,000",
                  "description": "This is a sample product."
                };

                Get.to(() => PromotedProductViewPage(productData: productData));
              },
              text: "Pay",
            ),
            spacer1(),
          ],
        ),
      ),
    );
  }
}
