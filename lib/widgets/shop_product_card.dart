import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/widgets/seller_product_menu.dart';
import 'package:flutter/material.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/constants/colors.dart';
import 'package:money_formatter/money_formatter.dart';

class ShopProductCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const ShopProductCard({
    super.key,
    required this.data,
  });

  @override
  State<ShopProductCard> createState() => _ShopProductCardState();
}

class _ShopProductCardState extends State<ShopProductCard> {
  late int currentIndex;
  final List<String> _images = [];

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
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
    MoneyFormatter fmf = MoneyFormatter(amount: 12345678.9012345);
    return GestureDetector(
      onTap: () {
        _showEditBottomSheet();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Image Section
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                  width: 100,
                  height: 100,
                  child: widget.data['ProductImages'].length > 0
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: widget.data['ProductImages'][0]["image"])
                      : Container()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParagraphText(
                      widget.data['description'] ?? "No description available",
                      maxLines: 2),
                  spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            ParagraphText(
                              "TZS ${MoneyFormatter(amount: double.parse(widget.data['sellingPrice'])).output.withoutFractionDigits}" ??
                                  "N/A",
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
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      ParagraphText(
                        widget.data['rating']?.toString() ?? "0",
                        color: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios,
              color: mutedTextColor,
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }
}
