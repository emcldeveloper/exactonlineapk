import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
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
import 'package:url_launcher/url_launcher.dart';

class SellerOrderViewPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const SellerOrderViewPage({super.key, required this.order});

  @override
  State<SellerOrderViewPage> createState() => _SellerOrderViewPageState();
}

class _SellerOrderViewPageState extends State<SellerOrderViewPage> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  void _removeProduct(int index) {
    setState(() {
      productItems.removeAt(index);
    });
  }

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
                        );
                      }).toList(),
                    ),
                    spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ParagraphText("Total Price"),
                        Builder(builder: (context) {
                          return Row(
                            children: [
                              ParagraphText(
                                  "TZS ${toMoneyFormmat(widget.order["totalPrice"].toString())}",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                              SizedBox(
                                width: 10,
                              ),
                              if (widget.order["status"] != "ORDERED" ||
                                  (widget.order["status"] != "DELIVERED"))
                                GestureDetector(
                                    onTap: () {
                                      Get.bottomSheet(SingleChildScrollView(
                                        child: Container(
                                          color: Colors.white,
                                          width: double.infinity,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 40, horizontal: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                HeadingText("Update price"),
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
                                                              widget
                                                                  .order["id"],
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
                                "This order is now active, you can proceed with delivery processes")),
                      ),
                    if (widget.order["status"] == "NEGOTIATION" ||
                        widget.order["status"] == "PENDING")
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
                    if (widget.order["status"] == "NEGOTIATION" ||
                        widget.order["status"] == "PENDING")
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
                                    "Agreed on this price ? press here to confirm order or continue negotiation with customer using buttons below "),
                              )
                            ],
                          ),
                        ),
                      ),
                    spacer3(),
                    if (widget.order["status"] == "ORDERED")
                      customButton(
                        buttonColor: Colors.amber,
                        textColor: Colors.black,
                        onTap: () {
                          OrdersController().editOrder(widget.order["id"],
                              {"status": "DELIVERED"}).then((res) {
                            setState(() {
                              widget.order["status"] = "DELIVERED";
                            });
                          });
                        },
                        text: "Mark as delivered",
                      ),
                    spacer(),
                    customButton(
                      onTap: () {
                        analytics.logEvent(
                          name: 'call_seller',
                          parameters: {
                            'seller_id': widget.order["OrderedProducts"]?[0]
                              ?["Product"]["ShopId"],
                              // 'shopName': widget.order["User"]["phone"],
                              // 'shopPhone': widget.order["User"]["phone"],
                              'from_page': 'SellerOrderViewPage'
                          },
                        );
                        launchUrl(Uri(
                            scheme: "tel",
                            path: widget.order["User"]["phone"]));
                      },
                      text: "Call Customer",
                    ),
                    spacer(),
                    customButton(
                      onTap: () {
                           analytics.logEvent(
                            name: 'chat_seller',
                            parameters: {
                              'seller_id': widget.order["OrderedProducts"]?[0]
                              ?["Product"]["ShopId"],
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
                      text: "Chat with Customer",
                      buttonColor: primaryColor,
                      textColor: Colors.black,
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
