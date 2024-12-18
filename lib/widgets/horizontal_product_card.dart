import 'package:e_online/widgets/popup_alert.dart';
import 'package:e_online/widgets/seller_product_menu.dart';
import 'package:flutter/material.dart';
import 'package:e_online/pages/product_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/constants/colors.dart';

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
  final List<String> _images = []; // Mock data for images
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
        _deleteProduct(); // Show the second popup
      },
    );
  }

  void _showEditBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ProductEditBottomSheet(
        onView: () {
          // Handle view logic
          Navigator.pop(context);
        },
        onReplace: () async {
          // Logic to replace the product image
          setState(() {
            if (currentIndex < _images.length) {
              _images[currentIndex] = 'new_image_path';
            }
          });
          Navigator.pop(context);
        },
        onDelete: () {
          // Logic to delete the product
          setState(() {
            if (currentIndex < _images.length) {
              _images.removeAt(currentIndex);
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(productData: widget.data),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: _showEditBottomSheet,
          child: Row(
            children: [
              // Image Section
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: widget.data['imageUrl'] != null
                      ? DecorationImage(
                          image: AssetImage(widget.data['imageUrl'][0]),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: primaryColor,
                ),
                child: widget.data['imageUrl'] == null
                    ? Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: primaryColor,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParagraphText(
                        widget.data['description'] ??
                            "No description available",
                        maxLines: 2),
                    spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              ParagraphText(
                                widget.data['price'] ?? "N/A",
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                              const SizedBox(width: 8),
                              ParagraphText(
                                "${widget.data['views'] ?? 0} views",
                                color: mutedTextColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            ParagraphText(
                              (widget.data['rating']?.toString() ?? "0"),
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
      ),
    );
  }
}
