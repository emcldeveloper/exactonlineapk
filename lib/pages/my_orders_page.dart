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

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final OrdersController ordersController = Get.put(OrdersController());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ordersController.getMyOrders(); // Load first page of orders

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        ordersController.getMyOrders(isRefresh: true); // Load more orders
      }
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

      body: Obx(() {
        if (ordersController.isLoading.value &&
            ordersController.myOrders.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.black));
        }

        return ordersController.myOrders.isEmpty
            ? noData()
            : ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: ordersController.myOrders.length + 1,
                itemBuilder: (context, index) {
                  if (index == ordersController.myOrders.length) {
                    return ordersController.isLoading.value
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: Colors.black)),
                          )
                        : const SizedBox();
                  }

                  var order = ordersController.myOrders[index];
                  return GestureDetector(
                    onTap: () => Get.to(CustomerOrderViewPage(order: order)),
                    child:
                        Column(children: [OrderCard(data: order), spacer2()]),
                  );
                },
              );
      }),
      // body: SingleChildScrollView(
      //   child: FutureBuilder(
      //       future: OrdersController().getMyOrders(1, 20, ""),
      //       builder: (context, snapshot) {
      //         if (snapshot.connectionState == ConnectionState.waiting) {
      //           return const Center(
      //               child: Padding(
      //             padding: EdgeInsets.all(30),
      //             child: CircularProgressIndicator(
      //               color: Colors.black,
      //             ),
      //           ));
      //         }
      //         List orders = snapshot.requireData;
      //         return orders.isEmpty
      //             ? noData()
      //             : Padding(
      //                 padding: const EdgeInsets.all(16.0),
      //                 child: Column(
      //                   children: orders.map((item) {
      //                     return GestureDetector(
      //                       onTap: () {
      //                         Get.to(CustomerOrderViewPage(order: item));
      //                       },
      //                       child: Column(
      //                         children: [
      //                           OrderCard(data: item),
      //                           spacer2(),
      //                         ],
      //                       ),
      //                     );
      //                   }).toList(),
      //                 ),
      //               );
      //       }),
      // ),
    );
  }
}
