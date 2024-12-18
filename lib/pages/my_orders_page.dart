import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/order_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  // This widget is the root of your application.
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
        title: HeadingText("My Orders"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: orderItems.map((item) {
              return Column(
                children: [
                  OrderCard(data: item),
                  spacer1(),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
