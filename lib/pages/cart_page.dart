import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/cart_products_controller.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/controllers/users_controllers.dart';
import 'package:e_online/main.dart';
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class CartPage extends StatefulWidget {
  CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  CartProductController cartProductController = Get.find();
  var loading = false.obs;
  var status = "ORDERED".obs;
  @override
  Widget build(BuildContext context) {
    // UsersControllers usersControllers = Get.find();
    // usersControllers.user;
    // var selectedOrderedProduct;
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
          title: HeadingText("My Cart"),
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
            future: CartProductController().getOnCartproducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              }
              List cartProducts = snapshot.requireData;
              print(cartProducts);
              return cartProducts.isEmpty
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
                                "You have selected ${cartProducts.length} products",
                                color: mutedTextColor),
                            spacer(),
                            Column(
                              children: cartProducts.map((item) {
                                return HorizontalProductCard(
                                  data: item,
                                  onRefresh: () {
                                    setState(() {});
                                    cartProductController.getOnCartproducts();
                                  },
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
                                  double totalPrice = 0.0;
                                  if (cartProducts.isNotEmpty) {
                                    totalPrice = cartProducts
                                        .map((item) => double.parse(
                                            item["Product"]["sellingPrice"]))
                                        .toList()
                                        .reduce((prev, item) => prev + item);
                                  }
                                  return ParagraphText(
                                      "TZS ${toMoneyFormmat(totalPrice.toString())}",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17);
                                })
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
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
                                          value: status.value == "NEGOTIATION",
                                          onChanged: (value) {
                                            if (value != true) {
                                              status.value = "ORDERED";
                                            } else {
                                              status.value = "NEGOTIATION";
                                            }
                                          }),
                                    ),
                                    ParagraphText(
                                        "I want to negotiate this price first")
                                  ],
                                ),
                              ),
                            ),
                            spacer3(),
                            Obx(
                              () => customButton(
                                loading: loading.value,
                                onTap: () async {
                                  try {
                                    // Set loading state
                                    loading.value = true;

                                    // Use Set<String> instead of dynamic Set for shop IDs
                                    Set<String> shops = {};
                                    for (var cartProduct in cartProducts) {
                                      shops.add(cartProduct["Product"]["Shop"]
                                              ["id"]
                                          .toString());
                                    }

                                    // Create list of futures for order creation
                                    List<Future<void>> orderPromises =
                                        shops.map((shopId) async {
                                      // Create order for each shop
                                      List shopProducts = cartProducts
                                          .where((element) =>
                                              element["Product"]["Shop"]["id"]
                                                  .toString() ==
                                              shopId)
                                          .toList();

                                      final orderResponse =
                                          await OrdersController().addOrder({
                                        "status": status.value,
                                        "totalPrice": shopProducts.reduce((prev,
                                                item) =>
                                            prev +
                                            item["Product"]["sellingPrice"]),
                                        "UserId": userController
                                            .user.value["id"]
                                            .toString(),
                                        "ShopId": shopId,
                                      });

                                      // Create ordered products futures
                                      List<Future> orderedProductPromises =
                                          shopProducts
                                              .map((cartProduct) =>
                                                  OrderedProductController()
                                                      .addOrderedProduct({
                                                    "OrderId":
                                                        orderResponse["id"]
                                                            .toString(),
                                                    "ProductId":
                                                        cartProduct["Product"]
                                                                ["id"]
                                                            .toString(),
                                                  }))
                                              .toList();

                                      // Wait for all ordered products to be added
                                      await Future.wait(orderedProductPromises);

                                      // Create delete cart products futures
                                      List<Future> deletePromises = shopProducts
                                          .map((cartProduct) =>
                                              CartProductController()
                                                  .deleteCartProduct(
                                                      cartProduct["id"]
                                                          .toString()))
                                          .toList();

                                      // Wait for all cart products to be deleted
                                      await Future.wait(deletePromises);
                                    }).toList();

                                    // Wait for all orders and their operations to complete
                                    await Future.wait(orderPromises);

                                    // Reset loading state on success
                                    loading.value = false;
                                    cartProductController.getOnCartproducts();
                                    setState(() {});
                                    // Optionally show success message
                                    // Get.snackbar("Success", "Order placed successfully");
                                  } catch (e) {
                                    // Handle errors
                                    loading.value = false;
                                    print("Error placing order: $e");
                                    // Optionally show error message
                                    // Get.snackbar("Error", "Failed to place order: $e");
                                  }
                                },
                                text: "Place an Order",
                              ),
                            ),
                            spacer3(),
                          ],
                        ),
                      ),
                    );
            }));
  }
}
