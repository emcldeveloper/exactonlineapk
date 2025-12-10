import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/pages/inventory/product_inventory_history_page.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class InventoryMainPage extends StatefulWidget {
  final String shopId;
  final String shopName;
  final bool showFAB;

  const InventoryMainPage({
    Key? key,
    required this.shopId,
    required this.shopName,
    this.showFAB = true,
  }) : super(key: key);

  @override
  State<InventoryMainPage> createState() => _InventoryMainPageState();
}

class _InventoryMainPageState extends State<InventoryMainPage> {
  String _searchQuery = '';
  List products = [];
  bool _isLoading = true;
  final ProductController productController = ProductController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchProducts({String? keyword}) async {
    setState(() => _isLoading = true);
    try {
      final res = await productController.getShopProducts(
        id: widget.shopId,
        page: 1,
        limit: 100,
        keyword: keyword,
      );
      setState(() {
        products = res ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _searchQuery = query;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchProducts(keyword: query.isEmpty ? null : query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats Cards
        Container(
          padding: const EdgeInsets.all(16),
          color: primary.withOpacity(0.08),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Products',
                  '${products.length}',
                  HugeIcons.strokeRoundedPackage,
                  primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Low Stock',
                  '${products.where((p) => (p['productQuantity'] ?? 0) < 10 && (p['productQuantity'] ?? 0) > 0).length}',
                  HugeIcons.strokeRoundedAlert02,
                  primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Out of Stock',
                  '${products.where((p) => (p['productQuantity'] ?? 0) == 0).length}',
                  HugeIcons.strokeRoundedCancelCircle,
                  primary,
                ),
              ),
            ],
          ),
        ),
        // Search and Filter
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              prefixIcon:
                  Icon(Icons.search, size: 20, color: Colors.grey.shade400),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear,
                          size: 20, color: Colors.grey.shade400),
                      onPressed: () => _onSearchChanged(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: primary.withOpacity(0.5), width: 1),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        // Products List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add products to manage inventory',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : MasonryGridView.count(
                      padding: const EdgeInsets.all(16),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(product);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          HugeIcon(icon: icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final productName = product['name'] ?? 'Unknown Product';
    final productImages = product['ProductImages'] ?? [];
    final productQuantity = product['productQuantity'] ?? 0;
    final productPrice = product['sellingPrice'] ?? 0;
    final isOutOfStock = productQuantity == 0;
    final isLowStock = productQuantity < 10 && productQuantity > 0;

    return GestureDetector(
      onTap: () async {
        final result =
            await Get.to(() => ProductInventoryHistoryPage(product: product));
        if (result == true) {
          // Refresh products after deletion or changes
          _fetchProducts(keyword: _searchQuery.isEmpty ? null : _searchQuery);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                color: Colors.grey[200],
                width: double.infinity,
                height: 160,
                child: productImages.isNotEmpty
                    ? CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: productImages[0]["image"],
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TZS ${MoneyFormatter(amount: double.tryParse(productPrice.toString()) ?? 0).output.withoutFractionDigits}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? Colors.red.shade50
                          : isLowStock
                              ? Colors.orange.shade50
                              : primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOutOfStock
                              ? HugeIcons.strokeRoundedUserWarning01
                              : isLowStock
                                  ? HugeIcons.strokeRoundedUserWarning01
                                  : HugeIcons.strokeRoundedCheckmarkBadge01,
                          size: 14,
                          color: isOutOfStock
                              ? Colors.red
                              : isLowStock
                                  ? Colors.orange
                                  : primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$productQuantity units',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock
                                ? Colors.red
                                : isLowStock
                                    ? Colors.orange
                                    : primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
