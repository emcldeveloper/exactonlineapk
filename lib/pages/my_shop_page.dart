import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/shop_controller.dart';
import 'package:e_online/pages/add_product_page.dart';
import 'package:e_online/pages/add_reel_page.dart';
import 'package:e_online/pages/create_ad_page.dart';
import 'package:e_online/pages/setting_myshop_page.dart';
import 'package:e_online/pages/shop_tabs/shop_orders.dart';
import 'package:e_online/pages/shop_tabs/shop_products.dart';
import 'package:e_online/pages/shop_tabs/shop_reels.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/widgets/ad_card.dart';
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

class MyShopPage extends StatefulWidget {
  const MyShopPage({super.key});

  @override
  _MyShopPageState createState() => _MyShopPageState();
}

class _MyShopPageState extends State<MyShopPage> {
  int _currentIndex = 0;
  final ShopController shopController = Get.put(ShopController());
  Rx<Map<String, dynamic>> shopDetails = Rx<Map<String, dynamic>>({});

  final List<Map<String, dynamic>> tilesItems = [
    {'points': "0", 'title': "Impressions"},
    {'points': "0", 'title': "Clicks"},
    {'points': "0", 'title': "Shares"},
    {'points': "0", 'title': "Calls"},
    {'points': "0", 'title': "Likes"},
    {'points': "0", 'title': "Profile Views"},
  ];

  final navCategories = [
    "Shop Products",
    "Reels",
    "My Orders",
    "Promoted",
    "Ads",
  ];

  @override
  void initState() {
    super.initState();
    _initializeShopDetails();
  }

  Future<void> _initializeShopDetails() async {
    try {
      final businessId = await SharedPreferencesUtil.getSelectedBusiness();
      final response = await shopController.getShopDetails(businessId);
      if (response) {
        shopDetails.value = response;
      }
    } catch (e) {
      print("Error fetching shop details: $e");
    }
  }

  void _handleAddAction({required BuildContext context, required Widget page}) {
    if (shopDetails.value.isNotEmpty &&
        shopDetails.value['isApproved'] == false) {
      _showApprovalBottomSheet(context);
    } else {
      Get.to(() => page);
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
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              // Metrics Tiles
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: tilesItems.map((item) {
                    return Column(
                      children: [
                        ParagraphText(
                          item['points'],
                          fontWeight: FontWeight.w700,
                        ),
                        ParagraphText(item['title'],
                            fontSize: 12, color: Colors.grey[600]),
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
        return "Add Order";
      case 3:
        return "Promote Product";
      case 4:
        return "Create Ad";
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
        page = SettingMyshopPage();
        break;
      case 4:
        page = const CreateAdPage();
        break;
    }

    if (page != null) {
      _handleAddAction(context: context, page: page);
    }
  }
}
