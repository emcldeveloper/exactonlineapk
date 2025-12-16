import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/shop_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/inventory/add_inventory_product_page.dart';
import 'package:e_online/pages/inventory/inventory_alerts_page.dart';
import 'package:e_online/pages/inventory/inventory_count_page.dart';
import 'package:e_online/pages/inventory/inventory_stock_reports_page.dart';
import 'package:e_online/pages/inventory/shop_users_page.dart';
import 'package:e_online/pages/inventory/inventory_main_page.dart';
import 'package:e_online/pages/setting_myshop_page.dart';
import 'package:e_online/pages/shop_chat_page.dart';
import 'package:e_online/pages/shop_tabs/shop_orders.dart';
import 'package:e_online/pages/pos/pos_main_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/widgets/newShopDetails.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/shop_password_dialog.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class ShopHomePage extends StatefulWidget {
  const ShopHomePage({Key? key}) : super(key: key);

  @override
  State<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  int _currentIndex = 0;
  final ShopController shopController = Get.put(ShopController());
  final UserController userController = Get.find();
  Rx<Map<String, dynamic>> shopDetails = Rx<Map<String, dynamic>>({});
  List<dynamic> availableShops = [];
  bool loading = true;
  Key _contentKey = UniqueKey();

  // Static map to store authenticated shops across the session
  static final Map<String, bool> _authenticatedShops = {};

  @override
  void initState() {
    super.initState();
    trackScreenView("ShopHomePage");
    availableShops = userController.user.value['Shops'] ?? [];
    _initializeShopDetails();
  }

  Future<void> _initializeShopDetails() async {
    try {
      final businessId = await SharedPreferencesUtil.getSelectedBusiness();

      if (businessId == null) {
        print("No business selected");
        setState(() => loading = false);
        return;
      }

      final response = await shopController.getShopDetails(businessId);

      if (response != null) {
        // Check if shop has password protection AND hasn't been authenticated in this session
        if (response['password'] != null &&
            !(_authenticatedShops[businessId] ?? false)) {
          _showPasswordDialog(response);
          return;
        }

        _processShopDetails(response);
      }
    } catch (e) {
      print("Error fetching shop details: $e");
      setState(() => loading = false);
    }
  }

  void _showPasswordDialog(Map<String, dynamic> shopData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ShopPasswordDialog(
        shopData: shopData,
        onPasswordCorrect: () {
          // Mark this shop as authenticated for this session
          _authenticatedShops[shopData['id']] = true;
          _processShopDetails(shopData);
        },
      ),
    );
  }

  void _processShopDetails(Map<String, dynamic> response) {
    shopDetails.value = response;
    setState(() {
      loading = false;
    });
  }

  Future<void> _switchBusiness(String businessId) async {
    try {
      setState(() => loading = true);

      // Save the new selected business
      await SharedPreferencesUtil.saveSelectedBusiness(businessId);

      // Reload shop details for the new business
      await _initializeShopDetails();

      // Refresh content
      setState(() {
        _contentKey = UniqueKey();
      });
    } catch (e) {
      print("Error switching business: $e");
      setState(() => loading = false);
    }
  }

  void _showBusinessDropdown() {
    if (availableShops.isEmpty) {
      Get.snackbar(
        "No Businesses",
        "You don't have any businesses set up yet.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: mainColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              spacer1(),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 228, 228, 228),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              spacer1(),
              ParagraphText(
                "Switch Business (${availableShops.length} available)",
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              spacer2(),
              ...availableShops.map((business) {
                bool isSelected = business['id'] == shopDetails.value['id'];
                return InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    if (!isSelected) {
                      await _switchBusiness(business['id']);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: primary, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.business,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ParagraphText(
                                business['name'] ?? 'Unnamed Business',
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                              if (business['description'] != null)
                                ParagraphText(
                                  business['description'],
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.grey[600],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              spacer2(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddAction(
      {required BuildContext context, required Widget page}) async {
    if (shopDetails.value.isNotEmpty &&
        shopDetails.value['isApproved'] == false) {
      _showDetailModal();
    } else {
      final result = await Get.to(() => page);

      // Refresh the page if an item was successfully added
      if (result == true) {
        setState(() {
          _contentKey = UniqueKey();
        });
      }
    }
  }

  void _showDetailModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => NewShopDetailsBottomSheet(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return InventoryMainPage(
          key: _contentKey,
          shopId: shopDetails.value['id'] ?? '',
          shopName: shopDetails.value['name'] ?? 'My Shop',
          showFAB: false,
        );
      case 1:
        return POSMainPage(
          key: _contentKey,
          shopId: shopDetails.value['id'] ?? '',
          shopName: shopDetails.value['name'] ?? 'My Shop',
        );
      case 2:
        return ShopOrders(key: _contentKey);
      case 3:
        return ShopChatPage();
      case 4:
        return SettingMyshopPage(from: "shoppingPage");
      default:
        return InventoryMainPage(
          key: _contentKey,
          shopId: shopDetails.value['id'] ?? '',
          shopName: shopDetails.value['name'] ?? 'My Shop',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            title: Obx(() => InkWell(
                  onTap: () {
                    if (availableShops.length > 0) {
                      _showBusinessDropdown();
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          shopDetails.value['name'] ?? "My Shop",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (availableShops.length > 1) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                )),
            centerTitle: true,
            actions: _currentIndex == 0
                ? [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        Get.to(() => const InventoryAlertsPage());
                      },
                      tooltip: 'Inventory Alerts',
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case 'count':
                            Get.to(() => const InventoryCountPage());
                            break;
                          case 'reports':
                            Get.to(() => InventoryStockReportsPage(
                                  shopId: shopDetails.value['id'] ?? '',
                                  shopName:
                                      shopDetails.value['name'] ?? 'My Shop',
                                ));
                            break;
                          case 'shop_users':
                            Get.to(() => ShopUsersPage(
                                  shopId: shopDetails.value['id'] ?? '',
                                  shopName:
                                      shopDetails.value['name'] ?? 'My Shop',
                                ));
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'shop_users',
                          child: Row(
                            children: [
                              Icon(Icons.people, color: primary),
                              const SizedBox(width: 8),
                              const Text('Shop Users'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'count',
                          child: Row(
                            children: [
                              Icon(Icons.checklist, color: primary),
                              const SizedBox(width: 8),
                              const Text('Count Inventory'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'reports',
                          child: Row(
                            children: [
                              Icon(Icons.assessment, color: primary),
                              const SizedBox(width: 8),
                              const Text('Stock Reports'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]
                : null,
          ),
          body: loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: primary,
                  ),
                )
              : _buildCurrentPage(),
          floatingActionButton: _currentIndex == 0
              ? FloatingActionButton.extended(
                  heroTag: 'shop_home_fab',
                  onPressed: () {
                    _handleAddAction(
                      context: context,
                      page: AddInventoryProductPage(
                        shopId: shopDetails.value['id'] ?? '',
                        shopName: shopDetails.value['name'] ?? 'My Shop',
                      ),
                    );
                  },
                  backgroundColor: primary,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Product',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: primary,
              unselectedItemColor: Colors.grey.shade600,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              backgroundColor: Colors.white,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedPackage,
                    color: Colors.grey,
                  ),
                  activeIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedPackage,
                    color: primary,
                  ),
                  label: 'Products',
                ),
                BottomNavigationBarItem(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedStore01,
                    color: Colors.grey,
                  ),
                  activeIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedStore01,
                    color: primary,
                  ),
                  label: 'POS',
                ),
                BottomNavigationBarItem(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedShoppingBag01,
                    color: Colors.grey,
                  ),
                  activeIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedShoppingBag01,
                    color: primary,
                  ),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedMessageMultiple02,
                    color: Colors.grey,
                  ),
                  activeIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedMessageMultiple02,
                    color: primary,
                  ),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedSettings02,
                    color: Colors.grey,
                  ),
                  activeIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedSettings02,
                    color: primary,
                  ),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
