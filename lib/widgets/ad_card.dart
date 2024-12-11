import 'package:e_online/widgets/promote_product_insights.dart';
import 'package:flutter/material.dart';
import 'package:e_online/pages/product_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/constants/colors.dart';

class AdCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const AdCard({Key? key, required this.data}) : super(key: key);

  @override
  State<AdCard> createState() => _HorizontalProductCardState();
}

class _HorizontalProductCardState extends State<AdCard> {
  late int currentIndex; // Index of the current product

  @override
  void initState() {
    super.initState();
    // Assume the product has an associated index in a larger list
    currentIndex = 0; // Initialize with default value, update as needed
  }

  void _showInsightsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PromoteProductInsightsBottomSheet(),
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
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: _showInsightsBottomSheet,
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
                          image: AssetImage(widget.data['imageUrl']),
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
                      widget.data['description'] ?? "No description available",
                      fontWeight: FontWeight.bold,
                    ),
                    spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              ParagraphText(
                                widget.data['price'] ?? "N/A",
                              ),
                              const SizedBox(width: 8),
                              ParagraphText(
                                "TZS ${widget.data['views'] ?? 0}",
                                color: mutedTextColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ParagraphText("free delivery", color: Colors.red)
                  ],
                ),
              ),
              const SizedBox(width: 15),
               Container(
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ParagraphText("Ad"),

          ),
        ),
            ],
          ),
        ),
      ),
    );
  }
}
