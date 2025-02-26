import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:flutter/material.dart';
import 'package:e_online/pages/product_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/constants/colors.dart';
import 'package:get/get.dart';

class FavoriteCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const FavoriteCard({
    super.key,
    required this.data,
  });

  @override
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.data);
    return GestureDetector(
      onTap: () {
        if (widget.data.isNotEmpty) {
          // print(widget.data["Product"]);
          Get.to(() => ProductPage(productData: widget.data));
        }
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
                width: 120,
                height: 120,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.data['ProductImages']?[0]?["image"] ?? "",
                  errorWidget: (context, url, error) =>
                      Icon(Icons.broken_image),
                ),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParagraphText(widget.data["name"] ?? "No name available",
                      maxLines: 2),
                  spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            ParagraphText(
                              "TZS ${toMoneyFormmat(widget.data['sellingPrice'])}",
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
                      // const SizedBox(width: 4),
                      // Row(
                      //   children: [
                      //     const Icon(Icons.star, color: Colors.amber, size: 16),
                      //     const SizedBox(width: 4),
                      //     ParagraphText(
                      //       widget.data['rating']?.toString() ?? "0",
                      //       color: Colors.black,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
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
