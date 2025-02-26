import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/order_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class ShopOrders extends StatelessWidget {
  const ShopOrders({super.key});

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
                          onTap: () {
                            Get.to(SellerOrderViewPage(order: item));
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
    );
  }
}
