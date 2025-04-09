import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/chat_controller.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerOrderViewPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const CustomerOrderViewPage({super.key, required this.order});

  @override
  State<CustomerOrderViewPage> createState() => _CustomerOrderViewPageState();
}

class _CustomerOrderViewPageState extends State<CustomerOrderViewPage> {
  @override
  void initState() {
    super.initState();
    trackScreenView("CustomerOrderViewPage");
  }

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  /// Groups products by shop ID
  Map<String, List<dynamic>> groupByShop(List<dynamic> orderedProducts) {
    Map<String, List<dynamic>> groupedOrders = {};
    for (var item in orderedProducts) {
      String shopId = item["Product"]["Shop"]["id"].toString();
      if (!groupedOrders.containsKey(shopId)) {
        groupedOrders[shopId] = [];
      }
      groupedOrders[shopId]!.add(item);
    }
    return groupedOrders;
  }

  UserController userController = Get.find();
  var status = "PENDING".obs;

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
        title: HeadingText(
            "Order #${widget.order['id'].toString().split('-').first}"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: FutureBuilder(
        future:
            OrderedProductController().getUserOrderproducts(widget.order["id"]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Center(child: noData());
          }

          List orderedProducts = snapshot.requireData;
          Map<String, List<dynamic>> groupedOrders =
              groupByShop(orderedProducts);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: groupedOrders.entries.map((entry) {
                  String shopId = entry.key;
                  List<dynamic> products = entry.value;
                  String shopName = products.first["Product"]["Shop"]["name"];
                  String shopPhone = products.first["Product"]["Shop"]["phone"];

                  double totalPrice = products
                      .map((item) =>
                          double.tryParse(
                              item["Product"]["sellingPrice"] ?? "0") ??
                          0)
                      .fold(0.0, (prev, item) => prev + item);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Shop Name
                      HeadingText(shopName,
                          fontSize: 18, fontWeight: FontWeight.bold),
                      spacer(),

                      /// Display all products under this shop
                      Column(
                        children: products
                            .map((item) => HorizontalProductCard(
                                  data: item,
                                  isOrder: true,
                                  onRefresh: () {
                                    setState(() {});
                                  },
                                ))
                            .toList(),
                      ),
                      spacer(),

                      /// Total Price for the Shop
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ParagraphText("Total Price"),
                          ParagraphText(
                            "TZS ${toMoneyFormmat(totalPrice.toString())}",
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ],
                      ),
                      spacer(),
                      if (widget.order["status"] == "DELIVERED")
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.green.withAlpha(30),
                              border: Border.all(
                                  color: Colors.green.withAlpha(60))),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ParagraphText(
                                  "Order is delivered successfully, thanks for using Exact Online")),
                        ),
                      if (widget.order["status"] == "ORDERED")
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.cyan.withAlpha(30),
                              border:
                                  Border.all(color: Colors.cyan.withAlpha(60))),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ParagraphText(
                                  "This order is now active, ${widget.order["Shop"]["name"]} will reach out to you for payment methods confirmation and delivery")),
                        ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (widget.order["status"] == "ORDERED")
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.orange.withAlpha(30),
                              border: Border.all(
                                  color: Colors.orange.withAlpha(60))),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.help,
                                color: Colors.orange,
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ParagraphText(
                                        "Warning",
                                      ),
                                      ParagraphText(
                                          "Do not pay before delivery",
                                          color: Colors.grey[700],
                                          fontSize: 12),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      if (widget.order["status"] == "NEGOTIATION" ||
                          widget.order["status"] == "PENDING")
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.orange.withAlpha(30),
                              border: Border.all(
                                  color: Colors.orange.withAlpha(60))),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Obx(
                                  () => Checkbox(
                                      activeColor: Colors.orange,
                                      value: status.value == "ORDERED",
                                      onChanged: (value) {
                                        status.value = "ORDERED";
                                        OrdersController().editOrder(
                                            widget.order["id"],
                                            {"status": "ORDERED"}).then((res) {
                                          setState(() {
                                            widget.order["status"] = "ORDERED";
                                          });
                                        });
                                      }),
                                ),
                                Expanded(
                                  child: ParagraphText(
                                      "Agreed on this price ? press here to confirm order or continue negotiation with seller using buttons below "),
                                )
                              ],
                            ),
                          ),
                        ),
                      spacer1(),

                      /// Call & Chat Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: customButton(
                              buttonColor: Colors.grey[200],
                              textColor: Colors.black,
                              onTap: () {
                                analytics.logEvent(
                                  name: 'chat_seller',
                                  parameters: {
                                    'seller_id': shopId,
                                    'shopName': shopName,
                                    'shopPhone': shopPhone,
                                    'from_page': 'CustomerOrderViewPage'
                                  },
                                );
                                ChatController().addChat({
                                  "ShopId": shopId,
                                  "OrderId": widget.order["id"],
                                  "UserId": userController.user.value["id"]
                                }).then((res) {
                                  Get.to(() => ConversationPage(res));
                                });
                              },
                              text: "Message Seller",
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: customButton(
                              onTap: () {
                                analytics.logEvent(
                                  name: 'call_seller',
                                  parameters: {
                                    'seller_id': shopId,
                                    'shopName': shopName,
                                    'shopPhone': shopPhone,
                                    'from_page': 'CustomerOrderViewPage'
                                  },
                                );
                                launchUrl(Uri(scheme: "tel", path: shopPhone));
                              },
                              text: "Call Seller",
                            ),
                          ),
                        ],
                      ),
                      spacer(),
                      spacer(),
                      spacer3(),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
