import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:get/get.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/utils/dio.dart';
import 'package:dio/dio.dart';

class InventoryCountPage extends StatefulWidget {
  const InventoryCountPage({Key? key}) : super(key: key);

  @override
  State<InventoryCountPage> createState() => _InventoryCountPageState();
}

class _InventoryCountPageState extends State<InventoryCountPage> {
  final ProductController productController = Get.put(ProductController());
  final UserController userController = Get.find();
  final Map<String, int> _countedProducts = {};
  bool _isCountMode = false;
  bool _isLoading = false;
  bool _isSaving = false;
  List<dynamic> _products = [];
  String? shopId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      shopId = await SharedPreferencesUtil.getCurrentShopId(
          userController.user.value["Shops"] ?? []);

      if (shopId != null) {
        final products = await productController.getShopProducts(
          id: shopId,
          page: 1,
          limit: 1000,
          keyword: _searchController.text,
        );

        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Failed to load products');
    }
  }

  int _getDiscrepancyCount() {
    int count = 0;
    for (var product in _products) {
      final productId = product['id'].toString();
      if (_countedProducts.containsKey(productId)) {
        final countedStock = _countedProducts[productId] ?? 0;
        final systemStock = (product['productQuantity'] ?? 0) is int
            ? product['productQuantity']
            : int.tryParse(product['productQuantity'].toString()) ?? 0;
        if (countedStock != systemStock) {
          count++;
        }
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory Count',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadProducts,
            tooltip: 'Refresh',
          ),
          if (_countedProducts.isNotEmpty)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveCount,
              tooltip: 'Save Count',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadProducts();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) => _loadProducts(),
            ),
          ),
          // Count Session Info
          Container(
            padding: const EdgeInsets.all(16),
            color: primary.withOpacity(0.08),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: primary),
                    const SizedBox(width: 8),
                    Text(
                      'Count Session: ${DateTime.now().toString().substring(0, 16)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Products Counted',
                        '${_countedProducts.length}',
                        Icons.check_circle,
                        primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Discrepancies',
                        '${_getDiscrepancyCount()}',
                        Icons.warning,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Toggle Count Mode
          Padding(
            padding: const EdgeInsets.all(16),
            child: SwitchListTile(
              value: _isCountMode,
              onChanged: (value) {
                setState(() {
                  _isCountMode = value;
                });
              },
              title: const Text('Quick Count Mode'),
              subtitle: const Text('Scan to increment count automatically'),
              secondary: const Icon(Icons.speed),
            ),
          ),
          // Products to Count
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final productId = product['id'].toString();
                          final productName =
                              product['name'] ?? 'Unknown Product';
                          final sku = product['productSKU'] ?? 'N/A';
                          final systemStock = (product['productQuantity'] ?? 0)
                                  is int
                              ? product['productQuantity']
                              : int.tryParse(
                                      product['productQuantity'].toString()) ??
                                  0;
                          final countedStock = _countedProducts[productId] ?? 0;
                          final hasCounted =
                              _countedProducts.containsKey(productId);
                          final hasDiscrepancy =
                              hasCounted && countedStock != systemStock;
                          final imageUrl =
                              (product['ProductImages'] as List?)?.isNotEmpty ==
                                      true
                                  ? product['ProductImages'][0]['image']
                                  : null;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: hasDiscrepancy ? 4 : 1,
                            color: hasDiscrepancy
                                ? Colors.orange.shade50
                                : hasCounted
                                    ? Colors.green.shade50
                                    : null,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: imageUrl != null
                                              ? DecorationImage(
                                                  image: NetworkImage(imageUrl),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: imageUrl == null
                                            ? Icon(
                                                Icons.inventory_2,
                                                color: Colors.grey.shade400,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              productName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'SKU: $sku',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (hasCounted)
                                        Icon(
                                          hasDiscrepancy
                                              ? Icons.warning
                                              : Icons.check_circle,
                                          color: hasDiscrepancy
                                              ? Colors.orange
                                              : Colors.green,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'System Stock',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            Text(
                                              '$systemStock units',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Counted',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.remove_circle),
                                                  onPressed: hasCounted &&
                                                          countedStock > 0
                                                      ? () {
                                                          setState(() {
                                                            _countedProducts[
                                                                    productId] =
                                                                countedStock -
                                                                    1;
                                                          });
                                                        }
                                                      : null,
                                                  color: Colors.red,
                                                ),
                                                Text(
                                                  '$countedStock',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: hasDiscrepancy
                                                        ? Colors.orange.shade700
                                                        : hasCounted
                                                            ? Colors
                                                                .green.shade700
                                                            : Colors
                                                                .grey.shade600,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.add_circle),
                                                  onPressed: () {
                                                    setState(() {
                                                      _countedProducts[
                                                              productId] =
                                                          countedStock + 1;
                                                    });
                                                  },
                                                  color: Colors.green,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Difference',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            Text(
                                              hasCounted
                                                  ? '${countedStock - systemStock > 0 ? '+' : ''}${countedStock - systemStock}'
                                                  : '-',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: hasDiscrepancy
                                                    ? Colors.orange.shade700
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _countedProducts.isNotEmpty && !_isSaving
          ? FloatingActionButton.extended(
              onPressed: _saveCount,
              backgroundColor: primary,
              icon: const Icon(Icons.save),
              label: const Text('Save Count',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            )
          : null,
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
          Icon(icon, color: color, size: 24),
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

  Future<void> _saveCount() async {
    final discrepancies = _getDiscrepancyCount();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Inventory Count'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Save count for ${_countedProducts.length} products?'),
            if (discrepancies > 0) const SizedBox(height: 8),
            if (discrepancies > 0)
              Text(
                'Found $discrepancies discrepancies.',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8),
            const Text(
              'This will update the system stock levels.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      int successCount = 0;
      int failCount = 0;

      for (var entry in _countedProducts.entries) {
        try {
          final productId = entry.key;
          final newQuantity = entry.value;

          await dio.patch(
            '/products/$productId',
            data: {'productQuantity': newQuantity},
            options: Options(headers: {
              'Authorization':
                  'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
            }),
          );
          successCount++;
        } catch (e) {
          failCount++;
        }
      }

      setState(() {
        _isSaving = false;
        _countedProducts.clear();
      });

      // Reload products to show updated quantities
      await _loadProducts();

      Get.snackbar(
        'Success',
        '$successCount products updated successfully${failCount > 0 ? ", $failCount failed" : ""}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      Get.snackbar('Error', 'Failed to save inventory count');
    }
  }
}
