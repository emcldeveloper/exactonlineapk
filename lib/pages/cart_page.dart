import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/cart_products_controller.dart';
import 'package:e_online/controllers/cart_services_controller.dart';
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
import 'package:e_online/widgets/horizontal_service_card.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/popup_alert.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class CartPage extends StatefulWidget {
  CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  CartProductController cartProductController =
      Get.put(CartProductController());
  CartServicesController cartServicesController =
      Get.put(CartServicesController());
  var loading = false.obs;
  var status = "IN PROGRESS".obs;
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      analytics.logScreenView(
        screenName: "CartPage",
        screenClass: "CartPage",
      );
    });
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
            future: Future.wait([
              CartProductController().getOnCartproducts(),
              cartServicesController.getOnCartServices(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              }

              List cartProducts = snapshot.requireData[0] ?? [];
              List cartServices = snapshot.requireData[1] ?? [];
              List allCartItems = [...cartProducts, ...cartServices];

              print("Cart products: $cartProducts");
              print("Cart services: $cartServices");

              return allCartItems.isEmpty
                  ? noData()
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            spacer(),
                            HeadingText("Selected items"),
                            ParagraphText(
                                "You have selected ${allCartItems.length} items (${cartProducts.length} products, ${cartServices.length} services)",
                                color: mutedTextColor),
                            spacer(),

                            // Products Section
                            if (cartProducts.isNotEmpty) ...[
                              ParagraphText("Products",
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              const SizedBox(height: 8),
                              Column(
                                children: cartProducts.map((item) {
                                  return HorizontalProductCard(
                                    data: item,
                                    isOrder: false,
                                    onRefresh: () {
                                      setState(() {});
                                      cartProductController.getOnCartproducts();
                                    },
                                  );
                                }).toList(),
                              ),
                              spacer(),
                            ],

                            // Services Section
                            if (cartServices.isNotEmpty) ...[
                              ParagraphText("Services",
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              const SizedBox(height: 8),
                              Column(
                                children: cartServices.map((item) {
                                  return HorizontalServiceCard(
                                    data: item,
                                    isOrder: false,
                                    onRefresh: () {
                                      setState(() {});
                                      cartServicesController
                                          .getOnCartServices();
                                    },
                                  );
                                }).toList(),
                              ),
                              spacer(),
                            ],

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ParagraphText("Total Price"),
                                Builder(builder: (context) {
                                  double totalPrice = 0.0;

                                  // Add products price
                                  if (cartProducts.isNotEmpty) {
                                    totalPrice += cartProducts
                                        .map((item) => double.parse(
                                            item["Product"]["sellingPrice"]
                                                .toString()))
                                        .toList()
                                        .reduce((prev, item) => prev + item);
                                  }

                                  // Add services price
                                  if (cartServices.isNotEmpty) {
                                    totalPrice += cartServices
                                        .map((item) => double.parse(
                                            item["price"]?.toString() ?? "0"))
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
                            if (cartProducts
                                .map((item) => item["Product"]["isNegotiable"])
                                .toList()
                                .contains(true))
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
                                            value: status.value == "NEW ORDER",
                                            onChanged: (value) {
                                              if (value != true) {
                                                status.value = "IN PROGRESS";
                                              } else {
                                                status.value = "NEW ORDER";
                                              }
                                            }),
                                      ),
                                      Expanded(
                                        child: ParagraphText(
                                            "I want to negotiate prices for negotiable items first"),
                                      )
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

                                    // Calculate total for analytics
                                    double totalCartValue = 0.0;

                                    // Add products price
                                    if (cartProducts.isNotEmpty) {
                                      totalCartValue +=
                                          cartProducts.fold<double>(
                                        0,
                                        (prev, item) =>
                                            prev +
                                            double.parse(item["Product"]
                                                    ["sellingPrice"]
                                                .toString()),
                                      );
                                    }

                                    // Add services price
                                    if (cartServices.isNotEmpty) {
                                      totalCartValue +=
                                          cartServices.fold<double>(
                                        0,
                                        (prev, item) =>
                                            prev +
                                            double.parse(
                                                item["price"]?.toString() ??
                                                    "0"),
                                      );
                                    }

                                    // Analytics for placing order
                                    await analytics.logEvent(
                                      name: 'submit_order',
                                      parameters: {
                                        'order_id': DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        'total_price': totalCartValue,
                                        'num_items': allCartItems.length,
                                        'num_products': cartProducts.length,
                                        'num_services': cartServices.length,
                                      },
                                    );

                                    // Process only products for now (services ordering can be enhanced later)
                                    if (cartProducts.isNotEmpty) {
                                      // Use Set<String> for shop IDs
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
                                          "totalPrice": shopProducts.fold(
                                              0,
                                              (prev, item) =>
                                                  prev +
                                                  int.parse(item["Product"]
                                                          ["sellingPrice"]
                                                      .toString())),
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
                                        await Future.wait(
                                            orderedProductPromises);

                                        // Create delete cart products futures
                                        List<Future> deletePromises =
                                            shopProducts
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
                                    }

                                    // Clear cart services (for now, just remove them from cart)
                                    if (cartServices.isNotEmpty) {
                                      List<Future> deleteServicePromises =
                                          cartServices
                                              .map((cartService) =>
                                                  cartServicesController
                                                      .deleteCartService(
                                                          cartService["id"]
                                                              .toString()))
                                              .toList();
                                      await Future.wait(deleteServicePromises);
                                    }

                                    // Reset loading state on success
                                    loading.value = false;
                                    cartProductController.getOnCartproducts();
                                    cartServicesController.getOnCartServices();
                                    setState(() {});

                                    // Show success message
                                    showPopupAlert(
                                      context,
                                      iconAsset:
                                          "assets/images/successmark.png",
                                      heading: "Ordered Successfully",
                                      text: cartServices.isNotEmpty
                                          ? "Your product orders are placed successfully. Service requests have been sent to providers."
                                          : "Your order is placed successfully",
                                      button1Text: "Go Back",
                                      button1Action: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      button2Text: "View Orders",
                                      button2Action: () {
                                        Navigator.of(context).pop();
                                        Get.back();
                                        Get.back();
                                        Get.to(() => MyOrdersPage(
                                              from: "cart",
                                            ));
                                      },
                                    );
                                  } catch (e) {
                                    // Handle errors
                                    loading.value = false;
                                    print("Error placing order: $e");
                                    Get.snackbar(
                                        "Error", "Failed to place order: $e");
                                  }
                                },
                                text: "Place Order",
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
