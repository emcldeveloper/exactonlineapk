import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/pages/customer_order_view_page.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/order_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

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
        child: FutureBuilder(
            future: OrdersController().getMyOrders(1, 20, ""),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ));
              }
              List orders = snapshot.requireData;
              return orders.isEmpty
                  ? noData()
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: orders.map((item) {
                          return GestureDetector(
                            onTap: () {
                              Get.to(CustomerOrderViewPage(order: item));
                            },
                            child: Column(
                              children: [
                                OrderCard(data: item),
                                spacer2(),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
            }),
      ),
    );
  }
}