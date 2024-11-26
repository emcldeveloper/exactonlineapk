import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class HorizontalProductCard extends StatelessWidget {
  final Map<String, dynamic> data; // Accepts a Map containing product details

  const HorizontalProductCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Image Section
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: data['imageUrl'] != null
                  ? DecorationImage(
                      image: AssetImage(data['imageUrl']),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.grey[200],
            ),
            child: data['imageUrl'] == null
                ? Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 12),

          // Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title or Description
                ParagraphText(
                  data['description'] ?? "No description available",
                  fontWeight: FontWeight.bold,
                ),
                spacer(),
                // Price and Views
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ParagraphText(
                            data['price'] ?? "N/A",
                          ),
                          const SizedBox(width: 8),
                          ParagraphText(
                            "${data['views'] ?? 0} views",
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
                      (data['rating']?.toString() ?? "0"),
                      color: Colors.black,
                    ),
                  ],
                ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // Arrow Icon
          Icon(
            Icons.arrow_forward_ios,
            color: mutedTextColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}
