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
  final OrdersController ordersController = Get.put(OrdersController());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ordersController.getShopOrders();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        ordersController.getShopOrders(isLoadMore: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ordersController.isLoading.value &&
          ordersController.shopOrders.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: Colors.black));
      }

      return ordersController.shopOrders.isEmpty
          ? noData()
          : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: ordersController.shopOrders.length + 1,
              itemBuilder: (context, index) {
                if (index == ordersController.shopOrders.length) {
                  return ordersController.isLoading.value
                      ? const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.black)),
                        )
                      : const SizedBox();
                }

                var order = ordersController.shopOrders[index];
                return GestureDetector(
                  onTap: () => Get.to(SellerOrderViewPage(order: order)),
                  child: Column(children: [OrderCard(data: order), spacer2()]),
                );
              },
            );
    });
  }
}
