import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/shop_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/shop_tabs/shop_products.dart';
import 'package:e_online/pages/shop_tabs/shop_reels.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class SellerProfilePage extends StatefulWidget {
  final String shopId;

  const SellerProfilePage({required this.shopId, Key? key}) : super(key: key);

  @override
  _SellerProfilePageState createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final ShopController shopController = Get.put(ShopController());
  final UserController userController = Get.find();
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
      // Send shop view statistics
      if (userId.isNotEmpty && id.isNotEmpty) {
        await _sendShopViewStats(id);
      }
    } catch (e) {
      debugPrint("Error fetching shop details: $e");
    }
  }

  Future<void> _sendShopViewStats(String shopId) async {
    try {
      var payload = {
        "ShopId": shopId,
        "UserId": userId,
      };

      await shopController.createShopStats(payload);
    } catch (e) {
      debugPrint("Error sending shop stats: $e");
    }
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
            InkWell(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                color: Colors.black,
                size: 22.0,
              ),
              onTap: () {},
            ),
            const SizedBox(width: 8),
            InkWell(
              child: const Icon(
                Icons.local_phone_outlined,
                color: Colors.black,
                size: 24,
              ),
              onTap: () {},
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {},
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedMessage01,
                color: Colors.black,
                size: 22.0,
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
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                            ), // Show a spinner while loading
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.store, // Fallback icon if loading fails
                            size: 80,
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
                                width: 60,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: isOpen
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                alignment: Alignment.center,
                                child: ParagraphText(
                                  isOpen ? "Open" : "Closed",
                                  color: isOpen
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                ),
                              ),
                            ],
                          ),
                          spacer(),
                          ParagraphText(
                            "Description",
                            fontWeight: FontWeight.bold,
                          ),
                          ParagraphText(data['description'] ??
                              "No description available."),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              spacer1(),
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Colors.black,
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
                          ShopProducts(),
                          ShopMasonryGrid(),
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
