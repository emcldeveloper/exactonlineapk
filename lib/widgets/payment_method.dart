import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/promoted_product_view_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  const PaymentMethodBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> paymentOptions = [
      {'imageUrl': 'assets/images/airtel.png'},
      {'imageUrl': 'assets/images/halopesa.png'},
      {'imageUrl': 'assets/images/mixxbyYas.jpg'},
      {'imageUrl': 'assets/images/mpesa.png'},
    ];

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
                        "Pay with mobile money",
                        fontWeight: FontWeight.bold,
                      ),
                      ParagraphText("Enter your phone number to pay", color: mutedTextColor),
                    ],
                  ),
                ),
                // Wrap the SizedBox in a Flexible widget to constrain its width
                Flexible(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: paymentOptions.map((option) {
                      return Container(
                        width: 70,
                        height: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          option['imageUrl'],
                          fit: BoxFit.contain,
                        ),
                      );
                    }).toList(),
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
                labelStyle: const TextStyle(color: Colors.black, fontSize: 12),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: primaryColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                hintText: "Write your phone number",
                hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            spacer1(),
            customButton(
              onTap: () {
                Map<String, dynamic> productData = {
                  "title": "Sample Product",
                  "price": "TZS 250,000",
                  "description": "This is a sample product.",
                };

                Get.to(() => PromotedProductViewPage(productData: productData));
              },
              text: "Pay",
            ),
            spacer2(),
          ],
        ),
      ),
    );
  }
}
