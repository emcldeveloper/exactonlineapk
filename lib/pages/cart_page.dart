import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: mutedTextColor,
            size: 14.0,
          ),
        ),
        title: HeadingText("Submit Order"),
        actions: const [
          Icon(
            Icons.settings_outlined,
            size: 16.0,
          ),
          SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: primaryColor,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              spacer(),
              HeadingText("Selected products"),
              ParagraphText("You have selected 3 products"),
              spacer(),
              Column(
                children: productItems.map((item) {
                  return HorizontalProductCard(data: item);
                }).toList(),
              ),
              spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ParagraphText("Total Price"),
                  ParagraphText("TZS 120,0000",
                      fontWeight: FontWeight.bold, fontSize: 17)
                ],
              ),
              spacer3(),
              customButton(
                onTap: () {},
                text: "Submit Order",
              ),
              spacer3(),
            ],
          ),
        ),
      ),
    );
  }
}
