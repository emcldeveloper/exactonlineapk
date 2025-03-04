import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/controllers/users_controllers.dart';
import 'package:e_online/pages/main_page.dart';
import 'package:e_online/pages/my_orders_page.dart';
import 'package:e_online/pages/setting_myshop_page.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/popup_alert.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class CartPage extends StatelessWidget {
  CartPage({super.key});
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  OrderedProductController orderedProductController = Get.find();
  var loading = false.obs;
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      analytics.logScreenView(
        screenName: "CartPage",
        screenClass: "CartPage",
      );
    });
    var selectedOrderedProduct;
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: mutedTextColor,
            size: 16.0,
          ),
        ),
        title: HeadingText("Cart Products"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: GetX<OrderedProductController>(
          init: orderedProductController,
          builder: (find) {
            return orderedProductController.productsOnCart.value.isEmpty
                ? noData()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          spacer(),
                          HeadingText("Selected products"),
                          ParagraphText(
                              "You have selected ${orderedProductController.productsOnCart.value.length} products",
                              color: mutedTextColor),
                          spacer(),
                          Column(
                            children: orderedProductController
                                .productsOnCart.value
                                .map((item) {
                              return HorizontalProductCard(data: item);
                            }).toList(),
                          ),
                          spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ParagraphText("Total Price"),
                              Builder(builder: (context) {
                                double totalPrice = orderedProductController
                                    .productsOnCart.value
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
                            loading: loading.value,
                            onTap: () async {
                              loading.value = true;
                              await analytics.logEvent(
                                name: 'submit_order',
                                parameters: {
                                  'order_id': orderedProductController
                                      .productsOnCart.value[0]["OrderId"],
                                  'amount': orderedProductController
                                      .productsOnCart.value
                                      .map((item) => double.parse(
                                          item["Product"]["sellingPrice"]))
                                      .toList()
                                      .reduce((prev, item) => prev + item),
                                },
                              );
                              OrdersController().editOrder(
                                  orderedProductController
                                      .productsOnCart.value[0]["OrderId"],
                                  {"status": "ORDERED"}).then((res) {
                                loading.value = false;
                                orderedProductController.getOnCartproducts();
                                showPopupAlert(
                                  context,
                                  iconAsset: "assets/images/successmark.png",
                                  heading: "Ordered successfully",
                                  text: "Your order is submitted successfully",
                                  button1Text: "Shop",
                                  button1Action: () {
                                    Navigator.of(context)
                                        .pop(); // Close the second popup
                                    Get.to(const MainPage());
                                  },
                                  button2Text: "View orders",
                                  button2Action: () {
                                    Navigator.of(context)
                                        .pop(); // Close the second popup and perform any additional action
                                    Get.to(const MyOrdersPage());
                                  },
                                );
                              });
                            },
                            text: "Submit Order",
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
