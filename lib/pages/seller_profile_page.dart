import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/chat_controller.dart';
import 'package:e_online/controllers/shop_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/pages/shop_tabs/shop_products.dart';
import 'package:e_online/pages/shop_tabs/shop_reels.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
            if (shopDetails.value['shopLat'] != null &&
                shopDetails.value['shopLong'] != null)
              InkWell(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedLocation01,
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
                if (await canLaunchUrlString(telUrl)) {
                  await launchUrlString(telUrl);
                } else {
                  debugPrint("Could not launch phone call.");
                }
              },
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                ChatController().addChat({
                  "ShopId": widget.shopId,
                  "UserId": userId,
                }).then((res) {
                  print(res);
                  Get.to(() => ConversationPage(res));
                });
              },
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                    fontSize: 12.0,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParagraphText(
                      "Description",
                      fontWeight: FontWeight.bold,
                    ),
                    ParagraphText(
                        data['description'] ?? "No description available.",
                        fontSize: 13.0),
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
