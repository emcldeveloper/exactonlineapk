import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/widgets/seller_service_menu.dart';
import 'package:flutter/material.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/constants/colors.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:money_formatter/money_formatter.dart';

class ShopServiceCard extends StatefulWidget {
  final Map<String, dynamic> data;
  Function onDelete;

  ShopServiceCard({
    super.key,
    required this.onDelete,
    required this.data,
  });

  @override
  State<ShopServiceCard> createState() => _ShopServiceCardState();
}

class _ShopServiceCardState extends State<ShopServiceCard> {
  final UserController userController = Get.find();
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
      builder: (context) => ServiceEditBottomSheet(
        selectedService: widget.data,
        onView: () {
          // Handle view logic
          Navigator.pop(context);
        },
        onReplace: () async {
          // Logic to replace the service image
          setState(() {
            if (currentIndex < _images.length) {
              _images[currentIndex] = 'new_image_path';
            }
          });
          Navigator.pop(context);
        },
        onDelete: () {
          // Logic to delete the service
          widget.onDelete();
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
              borderRadius: BorderRadius.circular(10),
              child: Container(
                  color: Colors.grey[200],
                  width: 120,
                  height: 120,
                  child: widget.data['ServiceImages'].length > 0
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: widget.data['ServiceImages'][0]["image"])
                      : Container()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParagraphText(
                      widget.data['name'] ?? "No description available",
                      maxLines: 2),
                  spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            ParagraphText(
                              "TZS ${MoneyFormatter(amount: double.parse(widget.data['price'])).output.withoutFractionDigits}" ??
                                  "N/A",
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(width: 4),
                      // const Icon(Icons.star, color: Colors.amber, size: 16),
                      // const SizedBox(width: 4),
                      // ParagraphText(
                      //   widget.data['rating']?.toString() ?? "0",
                      //   color: Colors.black,
                      // ),
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
