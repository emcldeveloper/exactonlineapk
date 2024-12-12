import 'package:e_online/pages/promote_product_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/promote_product_insights.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:get/get.dart';

class ProductEditBottomSheet extends StatefulWidget {
  final VoidCallback onView;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  const ProductEditBottomSheet({
    super.key,
    required this.onView,
    required this.onReplace,
    required this.onDelete,
  });

  @override
  State<ProductEditBottomSheet> createState() => _ProductEditBottomSheetState();
}

class _ProductEditBottomSheetState extends State<ProductEditBottomSheet> {
  @override
  Widget build(BuildContext context) {
    bool isSwitched = false;
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
                        "Product visibility",
                        fontWeight: FontWeight.bold,
                      ),
                      ParagraphText(
                        "When you hide product, customers won't see it ",
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isSwitched,
                  activeColor: Colors.black,
                  onChanged: (bool value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                ),
              ],
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

                Get.to(() => PromoteProductPage(productData: productData));
              },
              text: "Promote Product",
              vertical: 8.0,
              buttonColor: primaryColor,
              textColor: Colors.black,
            ),
            spacer1(),
            GestureDetector(
              onTap: () {
                Get.to(const PromoteProductInsightsBottomSheet());
              },
              child: Row(
                children: [
                  const Icon(Icons.upload_file_outlined),
                  const SizedBox(width: 8),
                  ParagraphText("Product insights"),
                ],
              ),
            ),
            spacer1(),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); 
                widget.onReplace();
              },
              child: Row(
                children: [
                  const Icon(Icons.edit_square),
                  const SizedBox(width: 8),
                  ParagraphText("Edit Product"),
                ],
              ),
            ),
            spacer1(),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onDelete();
              },
              child: Row(
                children: [
                  const Icon(Icons.delete_outline),
                  const SizedBox(width: 8),
                  ParagraphText("Delete Product"),
                ],
              ),
            ),
            spacer1(),
          ],
        ),
      ),
    );
  }
}
