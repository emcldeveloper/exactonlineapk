import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/shop_controller.dart';
import 'package:e_online/pages/add_product_page.dart';
import 'package:e_online/pages/add_reel_page.dart';
import 'package:e_online/pages/add_service_page.dart';
import 'package:e_online/pages/create_ad_page.dart';
import 'package:e_online/pages/setting_myshop_page.dart';
import 'package:e_online/pages/shop_chat_page.dart';
import 'package:e_online/pages/shop_tabs/shop_orders.dart';
import 'package:e_online/pages/shop_tabs/shop_products.dart';
import 'package:e_online/pages/shop_tabs/shop_reels.dart';
import 'package:e_online/pages/shop_tabs/shop_services.dart';
import 'package:e_online/pages/subscription_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/widgets/ad_card.dart';
import 'package:e_online/widgets/comingSoon.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/newShopDetails.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/order_card.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/shop_product_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';

class MyShopPage extends StatefulWidget {
  const MyShopPage({super.key});

  @override
  _MyShopPageState createState() => _MyShopPageState();
}

class _MyShopPageState extends State<MyShopPage> {
  int _currentIndex = 0;
  final ShopController shopController = Get.put(ShopController());
  Rx<Map<String, dynamic>> shopDetails = Rx<Map<String, dynamic>>({});
  bool loading = true;
  final List<Map<String, dynamic>> tilesItems = [
    {'title': "Followers"},
    {'title': "Impressions"},
    {'title': "Shares"},
    {'title': "Calls"},
    {'title': "Likes"},
    {'title': "Profile Views"},
  ];

  final navCategories = [
    "Shop Products",
    "Reels",
    "My Orders",
    "Shop Services",
    "Promoted",
    "Ads",
  ];

  @override
  void initState() {
    super.initState();
    trackScreenView("MyShopPage");
    _initializeShopDetails();
  }

  Future<void> _initializeShopDetails() async {
    try {
      final businessId = await SharedPreferencesUtil.getSelectedBusiness();

      if (businessId == null) {
        print("No business selected");
      }
      final response = await shopController.getShopDetails(businessId);
      print("🆑 ${businessId} ${response}");
      if (response != null) {
        // bool isSubscribed = response["isSubscribed"];
        bool isSubscribed = true;

        if (!isSubscribed) {
          Get.to(() => const SubscriptionPage());
        }
        shopDetails.value = response;
        setState(() {
          loading = false;
          tilesItems[0]['points'] =
              shopDetails.value['followers']?.toString() ?? "0";
          tilesItems[1]['points'] =
              shopDetails.value['impressions']?.toString() ?? "0";
          tilesItems[2]['points'] =
              shopDetails.value['shares']?.toString() ?? "0";
          tilesItems[3]['points'] =
              shopDetails.value['calls']?.toString() ?? "0";
          tilesItems[4]['points'] =
              shopDetails.value['reelLikes']?.toString() ?? "0";
          tilesItems[5]['points'] =
              shopDetails.value['profileViews']?.toString() ?? "0";
        });
      }
    } catch (e) {
      print("Error fetching shop details: $e");
    }
  }

  void _handleAddAction(
      {required BuildContext context, required Widget page}) async {
    if (shopDetails.value.isNotEmpty &&
        shopDetails.value['isApproved'] == false) {
      _showApprovalBottomSheet(context);
    } else {
      print("Going to: $page"); // Debug print
      await Get.to(() => Container(
            child: page,
          ));
      setState(() {});
    }
  }

  void _showApprovalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => NewShopDetailsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: navCategories.length,
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
          title: HeadingText("My Shop"),
          centerTitle: true,
          actions: [
            InkWell(
              onTap: () {
                Get.to(() => ShopChatPage());
              },
              child: Icon(
                AntDesign.message_outline,
                color: Colors.black,
                size: 22.0,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                Get.to(() => SettingMyshopPage(
                      from: "shoppingPage",
                    ));
              },
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSettings01,
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
        body: loading
            ? Center(
                child: const CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    // Metrics Tiles
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: tilesItems.map((item) {
                          return Column(
                            children: [
                              if (item['points'] != null)
                                ParagraphText(
                                  item['points'],
                                  fontWeight: FontWeight.w700,
                                ),
                              ParagraphText(item['title'],
                                  fontSize: 11.0, color: Colors.grey[600]),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    spacer1(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: customButton(
                        onTap: () => handleButtonAction(context),
                        text: getButtonText(),
                        vertical: 8.0,
                      ),
                    ),
                    spacer1(),
                    PreferredSize(
                      preferredSize: const Size.fromHeight(48.0),
                      child: TabBar(
                        onTap: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        dividerColor: const Color.fromARGB(255, 234, 234, 234),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        indicatorSize: TabBarIndicatorSize.label,
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black.withOpacity(0.5),
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        indicatorColor: Colors.black,
                        tabs: navCategories.map((category) {
                          return Tab(
                            child: Text(
                              category,
                              style: const TextStyle(fontSize: 15),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    spacer1(),
                    Expanded(
                      child: TabBarView(children: [
                        ShopProducts(),
                        ShopMasonryGrid(),
                        ShopOrders(),
                        ShopServices(),
                        noData(),
                        noData()
                      ]),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String getButtonText() {
    switch (_currentIndex) {
      case 0:
        return "Add New Product";
      case 1:
        return "Add Reel";
      case 2:
        return "Add New Product";
      case 4:
        return "Promote Product";
      case 5:
        return "Create Ad";
      case 3:
        return "Add New Service";
      default:
        return "Action";
    }
  }

  void handleButtonAction(BuildContext context) async {
    Widget? page;

    switch (_currentIndex) {
      case 0:
        page = const AddProductPage();
        break;
      case 1:
        page = const AddReelPage();
        break;
      case 2:
        page = const AddProductPage();
        break;
      case 3:
        page = const AddServicePage();
        break;
      case 4:
        page = SettingMyshopPage();
        break;
      case 5:
        page = const CreateAdPage();
        break;
    }

    if (page != null) {
      if (![0, 1, 2, 3].contains(_currentIndex)) {
        Get.bottomSheet(Container(
          color: Colors.white,
          child: CommingSoon(),
        ));
      } else {
        _handleAddAction(context: context, page: page);
      }
    }
  }
}
