import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/chat_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/shop_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/Seller_product_card.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/seller_reels.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SellerProfilePage extends StatefulWidget {
  final String shopId;

  const SellerProfilePage({required this.shopId, Key? key}) : super(key: key);

  @override
  _SellerProfilePageState createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final ShopController shopController = Get.put(ShopController());
  final UserController userController = Get.find();
  final ProductController productController = Get.put(ProductController());
  final RxList<dynamic> shopProducts = <dynamic>[].obs;
  final Rx<Map<String, dynamic>> shopDetails = Rx<Map<String, dynamic>>({});
  String userId = "";
  String today = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ][DateTime.now().weekday - 1];

  bool isOpen = false;
  @override
  void initState() {
    super.initState();
    _initializeShopDetails();
    trackScreenView("SellerProfilePage");
  }

  Future<void> _initializeShopDetails() async {
    try {
      String id = widget.shopId;
      final details = await shopController.getShopDetails(id);
      shopDetails.value = details;
      if (userController.user.value.containsKey("id")) {
        userId = userController.user.value["id"];
      }
      List<dynamic> shopCalenders = shopDetails.value['ShopCalenders'] ?? [];
      bool openStatus = shopCalenders
          .any((entry) => entry['day'] == today && entry['isOpen'] == true);

      setState(() {
        isOpen = openStatus;
      });
      await _fetchShopProducts();
      // Send shop view statistics
      if (userId.isNotEmpty && id.isNotEmpty) {
        await _sendShopViewStats(id);
      }
    } catch (e) {
      debugPrint("Error fetching shop details: $e");
    }
  }

  Future<void> _fetchShopProducts() async {
    try {
      String shopId = widget.shopId;
      var res = await productController.getShopProducts(
          id: shopId, page: 1, limit: 20);
      if (res != null) {
        shopProducts.assignAll(res);
      }
    } catch (e) {
      debugPrint("Error fetching shop products: $e");
    }
  }

  Future<void> _sendShopViewStats(String shopId) async {
    try {
      var payload = {
        "ShopId": shopId,
        "UserId": userId,
      };

      await analytics.logEvent(
        name: 'view_shop_profile',
        parameters: {
          "Shop_Id": shopId,
          "User_Id": userId,
          "shop_Name": shopDetails.value['name'],
          "address": shopDetails.value['address'],
        },
      );

      await shopController.createShopStats(payload);
    } catch (e) {
      debugPrint("Error sending shop stats: $e");
    }
  }

  void _shareShopProfile() async {
    const String appLink = "https://api.exactonline.co.tz/open-app/";

    String shopId = widget.shopId;
    String shopName = shopDetails.value['name'] ?? 'Check out this shop!';
    String address = shopDetails.value['address'] ?? '';
    String description =
        shopDetails.value['description'] ?? 'No description available.';
    String shareText =
        "Visit: $shopName shop, located at: $address\nDescription:$description";

    String fullAppLink = "$appLink?shopId=$shopId";

    await analytics.logEvent(
      name: 'share_shop',
      parameters: {
        'shop_id': shopId,
        'shop_Name': shopName,
        'shop_address': address,
        'shop_description': description,
        'link': fullAppLink,
      },
    );
    await Share.share(shareText +
        "\n\nCheck out this shop or explore more on ExactOnline!" +
        fullAppLink);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          title: HeadingText("Shop Details"),
          centerTitle: true,
          actions: [
            if (shopDetails.value['shopLat'] != null &&
                shopDetails.value['shopLong'] != null)
              InkWell(
                child: Icon(
                  Icons.pin_drop_outlined,
                  color: Colors.black,
                  size: 22.0,
                ),
                onTap: () async {
                  String googleMapsUrl =
                      "https://www.google.com/maps/search/?api=1&query=${shopDetails.value['shopLat']},${shopDetails.value['shopLong']}";
                  await launchUrlString(googleMapsUrl);
                },
              ),
            const SizedBox(width: 8),
            InkWell(
              child: const Icon(
                Icons.local_phone_outlined,
                color: Colors.black,
                size: 24,
              ),
              onTap: () async {
                String phoneNumber = shopDetails.value['phone'];
                String telUrl = "tel:$phoneNumber";

                await analytics.logEvent(
                  name: 'call_seller',
                  parameters: {
                    'seller_id': widget.shopId,
                    'shopName': shopDetails.value['name'],
                    'shopPhone': phoneNumber,
                    'from_page': 'SellerProfilePage'
                  },
                );

                if (await canLaunchUrlString(telUrl)) {
                  await launchUrlString(telUrl);
                } else {
                  debugPrint("Could not launch phone call.");
                }
              },
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                await analytics.logEvent(
                  name: 'chat_seller',
                  parameters: {
                    'seller_id': widget.shopId,
                    'shopName': shopDetails.value['name'],
                    'shopPhone': shopDetails.value['phone'],
                    'from_page': 'SellerProfilePage'
                  },
                );

                ChatController().addChat({
                  "ShopId": widget.shopId,
                  "UserId": userId,
                }).then((res) {
                  print(res);
                  Get.to(() => ConversationPage(res));
                });
              },
              child: Icon(
                Icons.chat_bubble_outline,
                color: Colors.black,
                size: 22.0,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _shareShopProfile,
              child: const Icon(
                Bootstrap.share,
                color: Colors.black,
                size: 20.0,
              ),
            ),
            const SizedBox(width: 16),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color.fromARGB(255, 242, 242, 242),
              height: 1.0,
            ),
          ),
        ),
        body: Obx(() {
          final data = shopDetails.value;

          if (data.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        height: 80,
                        width: 80,
                        child: CachedNetworkImage(
                          imageUrl: data['shopImage'] ?? '',
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            alignment: Alignment.center,
                            child: const Icon(
                              Bootstrap.shop,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HeadingText(data['name'] ?? 'Name'),
                                    ParagraphText(data['address'] ?? 'Address'),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: isOpen
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 2.0),
                                  child: ParagraphText(
                                    isOpen ? "Open" : "Closed",
                                    fontSize: 13.0,
                                    color: isOpen
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParagraphText(
                      "Description",
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    ParagraphText(
                        data['description'] ?? "No description available.",
                        fontSize: 14.0),
                  ],
                ),
              ),
              spacer1(),
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Colors.black,
                      dividerColor: const Color.fromARGB(255, 234, 234, 234),
                      indicatorSize: TabBarIndicatorSize.label,
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Colors.black,
                      unselectedLabelColor: mutedTextColor,
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 2,
                          color: Colors.black,
                        ),
                      ),
                      tabs: const [
                        Tab(text: "Shop Products"),
                        Tab(text: "Reels"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Obx(() => shopProducts.isEmpty
                              ? noData()
                              : ListView.builder(
                                  padding: EdgeInsets.all(16),
                                  itemCount: shopProducts.length,
                                  itemBuilder: (context, index) {
                                    return SellerProductCard(
                                        data: shopProducts[index]);
                                  },
                                )),
                          SellerMasonryGrid(widget.shopId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
