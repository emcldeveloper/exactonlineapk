import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/inventory/inventory_main_page.dart';
import 'package:e_online/utils/shared_preferences.dart';

class InventoryShopSelectionPage extends StatefulWidget {
  const InventoryShopSelectionPage({Key? key}) : super(key: key);

  @override
  State<InventoryShopSelectionPage> createState() =>
      _InventoryShopSelectionPageState();
}

class _InventoryShopSelectionPageState
    extends State<InventoryShopSelectionPage> {
  final UserController userController = Get.find();
  List<dynamic> availableShops = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  void _loadShops() {
    setState(() {
      availableShops = userController.user.value['Shops'] ?? [];
      loading = false;
    });
  }

  Future<void> _selectShop(String shopId, String shopName) async {
    await SharedPreferencesUtil.saveSelectedBusiness(shopId);
    Get.to(() => InventoryMainPage(shopId: shopId, shopName: shopName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Shop',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : availableShops.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No shops available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a shop to manage inventory',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableShops.length,
                  itemBuilder: (context, index) {
                    final shop = availableShops[index];
                    final shopName = shop['name'] ?? 'Unknown Shop';
                    final shopId = shop['id'];
                    final shopImage = shop['shopImage'];
                    final shopCategory = shop['address'] ?? 'General';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _selectShop(shopId, shopName),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Shop Image/Icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  image: shopImage != null
                                      ? DecorationImage(
                                          image: NetworkImage(shopImage),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: shopImage == null
                                    ? Icon(
                                        Icons.store,
                                        size: 30,
                                        color: primary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              // Shop Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shopName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      shopCategory,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow Icon
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
