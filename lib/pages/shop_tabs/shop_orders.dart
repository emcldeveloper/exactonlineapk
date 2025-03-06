import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/pages/seller_order_view_page.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/order_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopOrders extends StatefulWidget {
  const ShopOrders({super.key});

  @override
  State<ShopOrders> createState() => _ShopOrdersState();
}

class _ShopOrdersState extends State<ShopOrders> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
          future: OrdersController().getShopOrders(1, 20, ""),
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
                          onTap: () async {
                            await Get.to(SellerOrderViewPage(order: item));
                            setState(() {});
                          },
                          child: Column(
                            children: [
                              OrderCard(
                                data: item,
                                isUser: false,
                              ),
                              spacer2(),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
          }),
    );
  }
}
