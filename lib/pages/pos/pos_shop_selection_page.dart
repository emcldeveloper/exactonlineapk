import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/pos/pos_main_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class POSShopSelectionPage extends StatefulWidget {
  const POSShopSelectionPage({Key? key}) : super(key: key);

  @override
  State<POSShopSelectionPage> createState() => _POSShopSelectionPageState();
}

class _POSShopSelectionPageState extends State<POSShopSelectionPage> {
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final shops = userController.user.value['Shops'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Shop for POS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: shops.isEmpty
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
                    'No shops found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please create a shop first',
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
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                final shopName = shop['name'] ?? 'Unknown Shop';
                final shopCategory = shop['address'] ?? 'General';
                final shopImage =
                    shop['shopImages'] != null && shop['shopImages'].isNotEmpty
                        ? shop['shopImages'][0]['image']
                        : null;
                final shopId = shop['id'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Get.to(() => POSMainPage(
                            shopId: shopId,
                            shopName: shopName,
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Shop Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: shopImage != null
                                  ? CachedNetworkImage(
                                      imageUrl: shopImage,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.store,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.store,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Shop Info
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
                                Row(
                                  children: [
                                    Icon(
                                      Icons.category_outlined,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      shopCategory,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
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
