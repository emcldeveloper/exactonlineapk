import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/utils/snackbars.dart';
import 'package:e_online/widgets/popup_alert.dart';
import 'package:flutter/material.dart';
import 'package:e_online/pages/product_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/constants/colors.dart';
import 'package:get/get.dart';

import '../controllers/ordered_products_controller.dart';

class HorizontalProductCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onDelete;

  const HorizontalProductCard({
    super.key,
    required this.data,
    this.onDelete,
  });

  @override
  State<HorizontalProductCard> createState() => _HorizontalProductCardState();
}

class _HorizontalProductCardState extends State<HorizontalProductCard> {
  late int currentIndex; // Index of the current product
  void _deleteProduct() {
    // Handle product deletion and trigger callback
    if (widget.onDelete != null) {
      widget.onDelete!();
    }
  }

  OrderedProductController orderedProductController = Get.find();

  @override
  void initState() {
    super.initState();
    print(widget.data["Product"]["ProductImages"]);
    // Assume the product has an associated index in a larger list
    currentIndex = 0; // Initialize with default value, update as needed
  }

  void _showConfirmationPopup() {
    showPopupAlert(
      context,
      iconAsset: "assets/images/closeicon.jpg",
      heading: "Are you sure?",
      text: "Confirm removing product from an order",
      button1Text: "No",
      button1Action: () {
        Navigator.of(context).pop(); // Close the popup
      },
      button2Text: "Remove",
      button2Action: () {
        Navigator.of(context).pop(); // Close the first popup

        orderedProductController
            .deleteOrderedProduct(widget.data["id"])
            .then((res) {
          showSuccessSnackbar(
              title: "Removed Successfully",
              description: "Product is removed from the cart");
          orderedProductController.getOnCartproducts();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductPage(productData: widget.data["Product"]),
            ),
          );
        },
        child: Row(
          children: [
            // Image Section
            Container(
              width: 100,
              height: 100,
              child: CachedNetworkImage(
                  imageUrl: widget.data["Product"]["ProductImages"][0]
                      ['image']),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParagraphText(
                      widget.data["Product"]['description'] ??
                          "No description available",
                      maxLines: 2),
                  spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            ParagraphText(
                              "TZS ${toMoneyFormmat(widget.data["Product"]['sellingPrice'])}",
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                            const SizedBox(width: 8),
                            ParagraphText(
                              "${widget.data["Product"]['views'] ?? 0} views",
                              color: mutedTextColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          ParagraphText(
                            (widget.data["Product"]['rating']?.toString() ??
                                "0"),
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
            InkWell(
              onTap: _showConfirmationPopup,
              child: Icon(
                Icons.close,
                color: mutedTextColor,
                size: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
