import 'package:e_online/controllers/product_color_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/pages/edit_product_page.dart';
import 'package:e_online/pages/promote_product_page.dart';
import 'package:e_online/utils/snackbars.dart';
import 'package:e_online/widgets/comingSoon.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/popup_alert.dart';
import 'package:e_online/widgets/promote_product_insights.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:get/get.dart';

class ProductEditBottomSheet extends StatefulWidget {
  var selectedProduct;
  final VoidCallback onView;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  ProductEditBottomSheet({
    super.key,
    required this.selectedProduct,
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
                color: const Color.fromARGB(255, 228, 228, 228),
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
                        "Hide product",
                        fontWeight: FontWeight.bold,
                      ),
                      ParagraphText(
                        widget.selectedProduct["isHidden"]
                            ? "Product is now hidden to customers"
                            : "Product is visible to customers",
                        fontSize: 12.0,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: widget.selectedProduct["isHidden"],
                  inactiveThumbColor: Colors.grey[700],
                  inactiveTrackColor: Colors.white,
                  activeColor: Colors.green,
                  onChanged: (bool value) {
                    bool newValue = !widget.selectedProduct["isHidden"];
                    setState(() {
                      widget.selectedProduct["isHidden"] = newValue;
                    });
                    ProductController().editProduct(
                        widget.selectedProduct["id"], {"isHidden": newValue});
                  },
                ),
              ],
            ),
            // spacer1(),
            // customButton(
            //   onTap: () {
            //     // Example product data
            //     Map<String, dynamic> productData = {
            //       "title": "Sample Product",
            //       "price": "TZS 250,000",
            //       "description": "This is a sample product."
            //     };

            //     Get.bottomSheet(Container(
            //       color: Colors.white,
            //       child: CommingSoon(),
            //     ));
            //   },
            //   text: "Promote Product",
            //   vertical: 8.0,
            //   buttonColor: primaryColor,
            //   textColor: Colors.black,
            // ),
            // spacer1(),
            // GestureDetector(
            //   onTap: () {
            //     Get.to(const PromoteProductInsightsBottomSheet());
            //   },
            //   child: Row(
            //     children: [
            //       const Icon(Icons.upload_file_outlined),
            //       const SizedBox(width: 8),
            //       ParagraphText("Product insights"),
            //     ],
            //   ),
            // ),
            spacer1(),
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await Get.to(() => EditProductPage(
                      product: widget.selectedProduct,
                    ));
                widget.onDelete();
              },
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined),
                  const SizedBox(width: 8),
                  ParagraphText("Edit Product"),
                ],
              ),
            ),
            spacer1(),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                showPopupAlert(
                  context,
                  iconAsset: "assets/images/closeicon.jpg",
                  heading: "Delete",
                  text: "Are you sure you want to delete?",
                  button1Text: "No",
                  button1Action: () {
                    Get.back();
                  },
                  button2Text: "Yes",
                  button2Action: () async {
                    ProductController()
                        .deleteProduct(widget.selectedProduct["id"])
                        .then((res) {
                      Get.back();
                      showSuccessSnackbar(
                          title: "Deleted successfully",
                          description: "Product is deleted succesfully");
                      widget.onDelete();
                    });
                  },
                );
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
