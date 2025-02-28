import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/chat_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerOrderViewPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const CustomerOrderViewPage({super.key, required this.order});

  @override
  State<CustomerOrderViewPage> createState() => _CustomerOrderViewPageState();
}

class _CustomerOrderViewPageState extends State<CustomerOrderViewPage> {
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
        future:
            OrderedProductController().getUserOrderproducts(widget.order["id"]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Center(
                child: ParagraphText("No products found in this order."));
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
                            .map((item) => HorizontalProductCard(data: item))
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

                      /// Call & Chat Buttons
                      customButton(
                        onTap: () =>
                            launchUrl(Uri(scheme: "tel", path: shopPhone)),
                        text: "Call Seller",
                      ),
                      spacer(),
                      customButton(
                        onTap: () {
                          ChatController().addChat({
                            "ShopId": shopId,
                            "UserId": widget.order["UserId"]
                          }).then((res) {
                            widget.order["Products"] = products
                                .map((item) => item["Product"])
                                .toList();
                            // Get.to(() =>
                            //     ConversationPage(res, order: widget.order));
                          });
                        },
                        text: "Chat with Seller",
                        buttonColor: primaryColor,
                        textColor: Colors.black,
                      ),
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
