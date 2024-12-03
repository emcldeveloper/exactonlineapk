import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/promote_product_insights.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromotedProductViewPage extends StatefulWidget {
  final Map<dynamic, dynamic> productData;

  const PromotedProductViewPage({required this.productData, Key? key})
      : super(key: key);

  @override
  State<PromotedProductViewPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<PromotedProductViewPage> {
  void _showInsightsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PromoteProductInsightsBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: mutedTextColor,
            size: 14.0,
          ),
        ),
        title: HeadingText("Promote Product"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      "assets/images/shortsleeves.png",
                      height: 430,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                ],
              ),
              spacer(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ParagraphText(
                          widget.productData['title'] ?? '',
                          fontWeight: FontWeight.bold,
                        ),
                        ParagraphText(
                          widget.productData['price'] ?? '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ParagraphText(
                        "Promoted",
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
              spacer(),
              HeadingText("Promotion receipt"),
              spacer1(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ParagraphText(
                    "Total Amount:",
                    fontWeight: FontWeight.bold,
                  ),
                  ParagraphText("TZS 250,000", fontWeight: FontWeight.bold),
                ],
              ),
              spacer1(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ParagraphText(
                    "Tax:",
                    fontWeight: FontWeight.bold,
                  ),
                  ParagraphText("TZS 0", fontWeight: FontWeight.bold),
                ],
              ),
              spacer1(),
              customButton(
                onTap: _showInsightsBottomSheet,
                text: "View Insights",
              ),
              spacer2(),
            ],
          ),
        ),
      ),
    );
  }
}
