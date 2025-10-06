import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/chat_controller.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/text_form.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeline_list/timeline_list.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:e_online/utils/constants.dart";

class SellerOrderViewPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const SellerOrderViewPage({super.key, required this.order});

  @override
  State<SellerOrderViewPage> createState() => _SellerOrderViewPageState();
}

class _SellerOrderViewPageState extends State<SellerOrderViewPage> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    trackScreenView("SellerOrderViewPage");
  }

  var status = "PENDING".obs;
  TextEditingController priceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    print("Order 🆎");
    print(widget.order);
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
          future: OrderedProductController()
              .getShopOrderproducts(widget.order["id"]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            }
            List orderedProducts = snapshot.requireData;
            print("🍯");
            print(orderedProducts);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Column(
                      children: orderedProducts.map((item) {
                        return HorizontalProductCard(
                          data: item,
                          order: widget.order,
                          isOrder: true,
                        );
                      }).toList(),
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
                              Builder(builder: (context) {
                                return Row(
                                  spacing: 10,
                                  children: [
                                    ParagraphText(
                                        "TZS ${toMoneyFormmat(discount.toString())}",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                    if (widget.order["status"] == "NEW ORDER")
                                      GestureDetector(
                                          onTap: () {
                                            Get.bottomSheet(
                                                SingleChildScrollView(
                                              child: Container(
                                                color: Colors.white,
                                                width: double.infinity,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 40,
                                                      horizontal: 20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      HeadingText(
                                                          "Update price"),
                                                      TextForm(
                                                          label: "Order Price",
                                                          textEditingController:
                                                              priceController,
                                                          hint:
                                                              "Write order price here"),
                                                      customButton(
                                                          onTap: () {
                                                            Get.back();
                                                            setState(() {
                                                              widget.order[
                                                                      "totalPrice"] =
                                                                  priceController
                                                                      .text;
                                                            });
                                                            OrdersController()
                                                                .editOrder(
                                                                    widget.order[
                                                                        "id"],
                                                                    {
                                                                  "totalPrice":
                                                                      priceController
                                                                          .text
                                                                });
                                                          },
                                                          text: "Save Changes")
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ));
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.grey,
                                          ))
                                  ],
                                );
                              })
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeadingText("Order status", fontSize: 17),
                          Builder(builder: (context) {
                            var currentStep = steps.firstWhere((element) =>
                                element["value"] == widget.order["status"]);
                            return Timeline(
                              // Disable internal scrolling so only the outer SingleChildScrollView handles scroll
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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

                    spacer2(),
                    if (widget.order["status"] == "DELIVERED")
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.green.withAlpha(30),
                            border:
                                Border.all(color: Colors.green.withAlpha(60))),
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ParagraphText(
                                "Order is delivered successfully, thank you for using Exact Online")),
                      ),
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
                                "🔔 Alert: This order has been cancelled.")),
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
                                "This order is now active, you can proceed with delivery processes")),
                      ),
                    if (widget.order["status"] == "NEW ORDER")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.cyan.withAlpha(30),
                              border:
                                  Border.all(color: Colors.cyan.withAlpha(60))),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ParagraphText(
                                      "Customer wants to negotiate price"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (widget.order["status"] == "IN PROGRESS")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                        child: Container(
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
                                      "Please approve this order to inform user that you are working on it"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (widget.order["status"] == "CONFIRMED")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                        child: Container(
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
                                      "This order is now confirmed, you can go ahead with payment and delivery"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (widget.order["status"] == "NEW ORDER")
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.orange.withAlpha(30),
                            border:
                                Border.all(color: Colors.orange.withAlpha(60))),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Obx(
                                () => Checkbox(
                                    activeColor: Colors.orange,
                                    value: status.value == "IN PROGRESS",
                                    onChanged: (value) {
                                      status.value = "IN PROGRESS";
                                      OrdersController().editOrder(
                                          widget.order["id"], {
                                        "status": "IN PROGRESS  "
                                      }).then((res) {
                                        setState(() {
                                          widget.order["status"] =
                                              "IN PROGRESS";
                                        });
                                      });
                                    }),
                              ),
                              Builder(builder: (context) {
                                // Calculate if there's a discount
                                num subtotal = orderedProducts.fold<num>(
                                  0,
                                  (prev, item) =>
                                      prev +
                                      double.parse(item["Product"]
                                              ["sellingPrice"]
                                          .toString()),
                                );
                                num orderPrice = widget.order["totalPrice"];
                                bool hasDiscount = subtotal != orderPrice;

                                return Expanded(
                                  child: ParagraphText(hasDiscount
                                      ? "Agreed on this discounted price? Press here to confirm order or continue negotiation with customer using buttons below"
                                      : "Continue with product price if you are not giving discount"),
                                );
                              })
                            ],
                          ),
                        ),
                      ),
                    spacer3(),
                    if (!["CANCELED", "DELIVERED"]
                        .contains(widget.order["status"]))
                      Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () {
                                analytics.logEvent(
                                  name: 'call_seller',
                                  parameters: {
                                    'seller_id': widget.order["OrderedProducts"]
                                        ?[0]?["Product"]["ShopId"],
                                    // 'shopName': widget.order["User"]["phone"],
                                    // 'shopPhone': widget.order["User"]["phone"],
                                    'from_page': 'SellerOrderViewPage'
                                  },
                                );
                                launchUrl(Uri(
                                    scheme: "tel",
                                    path: widget.order["User"]["phone"]));
                              },
                              child: const Icon(
                                Icons.call,
                                color: Colors.black87,
                              )),
                          GestureDetector(
                              onTap: () {
                                analytics.logEvent(
                                  name: 'chat_seller',
                                  parameters: {
                                    'seller_id': widget.order["OrderedProducts"]
                                        ?[0]?["Product"]["ShopId"],
                                    // 'shopName': widget.order["User"]["phone"],
                                    // 'shopPhone': widget.order["User"]["phone"],
                                    'from_page': 'SellerOrderViewPage'
                                  },
                                );
                                ChatController().addChat({
                                  "ShopId": widget.order["ShopId"],
                                  "OrderId": widget.order["id"],
                                  "UserId": widget.order["UserId"]
                                }).then((res) {
                                  Get.to(() => ConversationPage(
                                        res,
                                        isUser: false,
                                      ));
                                });
                              },
                              child: const Icon(
                                Icons.message,
                                color: Colors.black87,
                              )),
                          if (widget.order["status"] != "CONFIRMED")
                            Expanded(
                              child: customButton(
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
                            ),
                          if (widget.order["status"] == "CONFIRMED")
                            Expanded(
                              child: customButton(
                                buttonColor: Colors.amber,
                                textColor: Colors.black,
                                onTap: () {
                                  OrdersController().editOrder(
                                      widget.order["id"],
                                      {"status": "DELIVERED"}).then((res) {
                                    setState(() {
                                      widget.order["status"] = "DELIVERED";
                                    });
                                  });
                                },
                                text: "Confirm Pickup/Delivery",
                              ),
                            ),
                          if (widget.order["status"] == "IN PROGRESS")
                            Expanded(
                              child: customButton(
                                buttonColor: Colors.amber,
                                textColor: Colors.black,
                                onTap: () {
                                  OrdersController().editOrder(
                                      widget.order["id"],
                                      {"status": "CONFIRMED"}).then((res) {
                                    setState(() {
                                      widget.order["status"] = "CONFIRMED";
                                    });
                                  });
                                },
                                text: "Approve",
                              ),
                            ),
                        ],
                      ),
                    spacer3(),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
