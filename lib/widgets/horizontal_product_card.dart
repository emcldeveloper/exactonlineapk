import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/controllers/cart_products_controller.dart';
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
  final Function? onRefresh;
  bool? isOrder;
  Map<String, dynamic>? order;
  HorizontalProductCard({
    super.key,
    required this.data,
    this.order,
    this.onRefresh,
    this.isOrder = false,
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

  @override
  void initState() {
    super.initState();
    print(widget.data);
    // print(widget.data["Product"]["ProductImages"]);
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
        if (widget.isOrder == true) {
          OrderedProductController()
              .deleteOrderedProduct(widget.data["id"])
              .then((res) {
            showSuccessSnackbar(
                title: "Removed Successfully",
                description: "Product is removed from the order");
            // Navigator.of(context).pop(); // Close the first popup
            widget.onRefresh!();
            // orderedProductController.getOnCartproducts();
          });
        } else {
          CartProductController()
              .deleteCartProduct(widget.data["id"])
              .then((res) {
            showSuccessSnackbar(
                title: "Removed Successfully",
                description: "Product is removed from the cart");
            // Navigator.of(context).pop(); // Close the first popup
            widget.onRefresh!();
            // orderedProductController.getOnCartproducts();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 120,
              height: 120,
              child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.data["Product"]["ProductImages"][0]
                      ['image']),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParagraphText(
                    widget.data["Product"]['name'] ?? "No name available",
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
                        ],
                      ),
                    ),
                  ],
                ),
                ParagraphText(
                    widget.data["Product"]?['Shop']?["name"] ??
                        "No name available",
                    color: primary,
                    maxLines: 2),
                if (widget.data["Product"]["isNegotiable"] == true)
                  ParagraphText("* price is negotiable",
                      color: Colors.grey, maxLines: 2),
              ],
            ),
          ),
          const SizedBox(width: 30),
          if (widget.isOrder == false)
            InkWell(
              onTap: _showConfirmationPopup,
              child: Icon(
                Icons.close,
                color: mutedTextColor,
                size: 16.0,
              ),
            ),
          if (widget.isOrder == true)
            if (widget.order != null)
              if (widget.order!["status"] == "NEW ORDER")
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
    );
  }
}
