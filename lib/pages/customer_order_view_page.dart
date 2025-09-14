import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/chat_controller.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/utils/constants.dart';
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
import 'package:timeline_list/timeline_list.dart';

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
          print("🅰️");
          print(orderedProducts);
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
                                  order: widget.order,
                                  onRefresh: () {
                                    setState(() {});
                                  },
                                ))
                            .toList(),
                      ),
                      spacer(),

                      /// payment summary
                      Builder(builder: (context) {
                        num subtotal = orderedProducts.fold<num>(
                          0,
                          (prev, item) =>
                              prev +
                              double.parse(
                                  item["Product"]["sellingPrice"].toString()),
                        );
                        num orderPrice = widget.order["totalPrice"];
                        num discount = subtotal - orderPrice;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ParagraphText("Sub Total"),
                                ParagraphText(
                                    "TZS ${toMoneyFormmat(subtotal.toString())}",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ParagraphText("Tax"),
                                ParagraphText("TZS 0",
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ParagraphText("Discount"),
                                ParagraphText(
                                    "TZS ${toMoneyFormmat(discount.toString())}",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ],
                            ),
                            spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ParagraphText("Total Cost"),
                                ParagraphText(
                                    "TZS ${toMoneyFormmat(orderPrice.toString())}",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ],
                            ),
                          ],
                        );
                      }),
                      if (widget.order["status"] != "CANCELED")
                        const SizedBox(
                          height: 20,
                        ),
                      if (widget.order["status"] != "CANCELED")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeadingText("Order status", fontSize: 17),
                            Builder(builder: (context) {
                              var currentStep = steps.firstWhere((element) =>
                                  element["value"] == widget.order["status"]);
                              return Timeline(
                                properties: const TimelineProperties(
                                    iconSize: 20,
                                    iconAlignment: MarkerIconAlignment.center),
                                children: steps
                                    .map((item) => Marker(
                                        icon: ClipOval(
                                          child: Container(
                                              color: currentStep["index"] >=
                                                      item["index"]
                                                  ? Colors.green
                                                  : Colors.grey[400],
                                              child: Icon(
                                                Icons.check,
                                                color: currentStep["index"] >=
                                                        item["index"]
                                                    ? Colors.white
                                                    : Colors.black,
                                                size: 15,
                                              )),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            HeadingText(item["step"],
                                                fontSize: 14),
                                            ParagraphText(item["subtitle"],
                                                color: Colors.grey[600])
                                          ],
                                        )))
                                    .toList(),
                              );
                            }),
                          ],
                        ),
                      if (widget.order["status"] == "CANCELED" ||
                          widget.order["status"] == "CONFIRMED")
                        spacer2(),
                      if (widget.order["status"] == "CANCELED")
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.red.withAlpha(30),
                              border:
                                  Border.all(color: Colors.red.withAlpha(40))),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ParagraphText(
                                  "🔔 Alert: Your order has been cancelled.")),
                        ),
                      if (widget.order["status"] == "CONFIRMED")
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
                                  "🔔 Your order is now active! ${widget.order["Shop"]["name"]} will contact you shortly with payment instructions and delivery or pickup details.")),
                        ),
                      const SizedBox(
                        height: 5,
                      ),
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
                                  "Your order has been delivered successfully. Please confirm receipt. Thank you for using ExactOnline.")),
                        ),
                      spacer1(),
                      if (widget.order["status"] == "CONFIRMED")
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.orange.withAlpha(30),
                              border: Border.all(
                                  color: Colors.orange.withAlpha(60))),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ParagraphText(
                                "⚠️ Warning: Do Not Pay Before Pickup or Delivery!",
                              )),
                        ),
                      // ParagraphText(widget.order["status"]),
                      if (widget.order["status"] == "NEW ORDER")
                        Builder(builder: (context) {
                          // Calculate if there's a discount
                          num subtotal = orderedProducts.fold<num>(
                            0,
                            (prev, item) =>
                                prev +
                                double.parse(
                                    item["Product"]["sellingPrice"].toString()),
                          );
                          num orderPrice = widget.order["totalPrice"];
                          bool hasDiscount = subtotal != orderPrice;

                          // Only show the whole container if seller has given a discount
                          return hasDiscount
                              ? Container(
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
                                              value:
                                                  status.value == "IN PROGRESS",
                                              onChanged: (value) {
                                                status.value = "IN PROGRESS";
                                                OrdersController().editOrder(
                                                    widget.order["id"], {
                                                  "status": "IN PROGRESS"
                                                }).then((res) {
                                                  setState(() {
                                                    widget.order["status"] =
                                                        "IN PROGRESS";
                                                  });
                                                });
                                              }),
                                        ),
                                        Expanded(
                                          child: ParagraphText(
                                              "Agreed on this price? Press here to confirm order or continue negotiation with seller using buttons below"),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox
                                  .shrink(); // Hide entire container if no discount
                        }),

                      spacer1(),
                      if (widget.order["status"] == "IN PROGRESS")
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
                                Expanded(
                                  child: ParagraphText(
                                      "🔔 Awaiting seller confirmation."),
                                )
                              ],
                            ),
                          ),
                        ),
                      spacer1(),

                      // Call & Chat Buttons
                      if (!["CANCELED"].contains(widget.order["status"]))
                        Row(
                          spacing: 5,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                  launchUrl(
                                      Uri(scheme: "tel", path: shopPhone));
                                },
                                text: "Call",
                                buttonColor: Colors.black12.withAlpha(10),
                                textColor: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: customButton(
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
                                text: "Message",
                                buttonColor: Colors.black87,
                                textColor: Colors.white,
                              ),
                            ),
                            if (widget.order["status"] == "NEW ORDER")
                              customButton(
                                onTap: () {
                                  OrdersController().editOrder(
                                      widget.order["id"],
                                      {"status": "CANCELED"}).then((res) {
                                    setState(() {
                                      widget.order["status"] = "CANCELED";
                                    });
                                  });
                                },
                                text: "Cancel order",
                                buttonColor: primaryColor,
                                textColor: Colors.red,
                              ),
                            if (widget.order["status"] == "DELIVERED")
                              customButton(
                                onTap: () {
                                  OrdersController().editOrder(
                                      widget.order["id"],
                                      {"status": "CLOSED"}).then((res) {
                                    setState(() {
                                      widget.order["status"] = "CLOSED";
                                    });
                                  });
                                },
                                text: "Confirm Delivery",
                                buttonColor: Colors.amber,
                                textColor: Colors.black,
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
