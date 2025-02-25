import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
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
  void _removeProduct(int index) {
    setState(() {
      productItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Ordered 🌕");
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
        title: HeadingText("Order ${widget.order['id']}"),
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
              .getUserOrderproducts(widget.order["id"]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: const CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            }
            List orderedProducts = snapshot.requireData;

            print("Ordered products ${orderedProducts}");
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
                          double totalPrice = 0;
                          if (orderedProducts.length > 0)
                            orderedProducts
                                .map((item) => double.parse(
                                    item["Product"]["sellingPrice"]))
                                .toList()
                                .reduce((prev, item) => prev + item);
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
                        launchUrl(Uri(
                            scheme: "tel",
                            path: widget.order["OrderedProducts"]?[0]
                                ?["Product"]["Shop"]["phone"]));
                      },
                      text: "Call Seller",
                    ),
                    spacer(),
                    customButton(
                      onTap: () {
                        ChatController().addChat({
                          "ShopId": widget.order["OrderedProducts"]?[0]
                              ?["Product"]["Shop"]["id"],
                          "UserId": widget.order["UserId"]
                        }).then((res) {
                          print(res);
                          Get.to(() => ConversationPage(
                                res,
                                order: widget.order,
                              ));
                        });
                      },
                      text: "Chat with Seller",
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
