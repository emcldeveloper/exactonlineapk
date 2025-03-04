import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/chat_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
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
            "Order ${widget.order['id'].toString().split('-').first}"),
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
                          print(orderedProducts
                              .map((item) => item["Product"]["sellingPrice"]));
                          double totalPrice = orderedProducts
                              .map((item) =>
                                  double.tryParse(
                                      item["Product"]["sellingPrice"] ?? "0") ??
                                  0)
                              .fold(0.0, (prev, item) => prev + item);

                          return ParagraphText(
                              "TZS ${toMoneyFormmat(totalPrice.toString())}",
                              fontWeight: FontWeight.bold,
                              fontSize: 17);
                        })
                      ],
                    ),
                    spacer3(),
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
                          "ShopId": widget.order["OrderedProducts"]?[0]
                              ?["Product"]["ShopId"],
                          "UserId": widget.order["UserId"]
                        }).then((res) {
                          print(res);
                          widget.order["Products"] =
                              orderedProducts.map((item) => item["Product"]);
                          // Get.to(() => ConversationPage(
                          //       res,
                          //       order: widget.order,
                          //     ));
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
