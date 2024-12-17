import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerOrderViewPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const CustomerOrderViewPage({super.key, required this.orderData});

  @override
  State<CustomerOrderViewPage> createState() => _CustomerOrderViewPageState();
}

class _CustomerOrderViewPageState extends State<CustomerOrderViewPage> {
  void _removeProduct(int index) {
    setState(() {
      productItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios,
            color: mutedTextColor,
            size: 16.0,
          ),
        ),
        // Use the name from orderData in the title
        title: HeadingText("Order ${widget.orderData['orderNo']}"),
        centerTitle: true,
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
              Column(
                children: List.generate(productItems.length, (index) {
                  return HorizontalProductCard(
                    data: productItems[index],
                    onDelete: () => _removeProduct(index),
                  );
                }),
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
                text: "Call Customer",
              ),
              spacer(),
              customButton(
                onTap: () {},
                text: "Chat with Customer",
                buttonColor: primaryColor,
                textColor: Colors.black,
              ),
              spacer3(),
            ],
          ),
        ),
      ),
    );
  }
}
