import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InventoryStockReportsPage extends StatefulWidget {
  final String shopId;
  final String shopName;

  const InventoryStockReportsPage({
    Key? key,
    required this.shopId,
    required this.shopName,
  }) : super(key: key);

  @override
  State<InventoryStockReportsPage> createState() =>
      _InventoryStockReportsPageState();
}

class _InventoryStockReportsPageState extends State<InventoryStockReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProductController productController = ProductController();

  List products = [];
  bool _isLoading = true;

  // Stats
  int totalProducts = 0;
  int inStockProducts = 0;
  int lowStockProducts = 0;
  int outOfStockProducts = 0;
  double totalStockValue = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final res = await productController.getShopProducts(
        id: widget.shopId,
        page: 1,
        limit: 1000, // Get all products for report
      );

      setState(() {
        products = res ?? [];
        _calculateStats();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  void _calculateStats() {
    totalProducts = products.length;
    inStockProducts =
        products.where((p) => (p['productQuantity'] ?? 0) >= 10).length;
    lowStockProducts = products.where((p) {
      final qty = p['productQuantity'] ?? 0;
      return qty > 0 && qty < 10;
    }).length;
    outOfStockProducts =
        products.where((p) => (p['productQuantity'] ?? 0) == 0).length;

    totalStockValue = products.fold(0.0, (sum, p) {
      final qty = (p['productQuantity'] ?? 0).toDouble();
      final price = double.tryParse(p['sellingPrice']?.toString() ?? '0') ?? 0;
      return sum + (qty * price);
    });
  }

  List _getFilteredProducts(String filter) {
    switch (filter) {
      case 'all':
        return products;
      case 'in_stock':
        return products
            .where((p) => (p['productQuantity'] ?? 0) >= 10)
            .toList();
      case 'low_stock':
        return products.where((p) {
          final qty = p['productQuantity'] ?? 0;
          return qty > 0 && qty < 10;
        }).toList();
      case 'out_of_stock':
        return products.where((p) => (p['productQuantity'] ?? 0) == 0).toList();
      default:
        return products;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stock Reports',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.shopName,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'In Stock'),
            Tab(text: 'Low Stock'),
            Tab(text: 'Out of Stock'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Stats Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: primary.withOpacity(0.08),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Products',
                              totalProducts.toString(),
                              Icons.inventory_2,
                              primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Value',
                              'TZS ${MoneyFormatter(amount: totalStockValue).output.withoutFractionDigits}',
                              Icons.attach_money,
                              Colors.green,
                              isValue: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallCard(
                              'In Stock',
                              inStockProducts.toString(),
                              primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSmallCard(
                              'Low Stock',
                              lowStockProducts.toString(),
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSmallCard(
                              'Out of Stock',
                              outOfStockProducts.toString(),
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tabs Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductList('all'),
                      _buildProductList('in_stock'),
                      _buildProductList('low_stock'),
                      _buildProductList('out_of_stock'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color,
      {bool isValue = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isValue ? 14 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
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
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(String filter) {
    final filteredProducts = _getFilteredProducts(filter);

    if (filteredProducts.isEmpty) {
      return Center(
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
              'No products in this category',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final productName = product['name'] ?? 'Unknown Product';
    final productImages = product['ProductImages'] ?? [];
    final productQuantity = product['productQuantity'] ?? 0;
    final productPrice = product['sellingPrice'] ?? 0;
    final isOutOfStock = productQuantity == 0;
    final isLowStock = productQuantity < 10 && productQuantity > 0;

    final stockValue =
        productQuantity * (double.tryParse(productPrice.toString()) ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOutOfStock
              ? Colors.red.shade200
              : isLowStock
                  ? Colors.orange.shade200
                  : Colors.grey.shade200,
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
      child: Row(
        children: [
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: Colors.grey[200],
              width: 80,
              height: 80,
              child: productImages.isNotEmpty
                  ? CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: productImages[0]["image"],
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image_outlined,
                        size: 30,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.image_outlined,
                      size: 30,
                      color: Colors.grey,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? Colors.red.shade50
                            : isLowStock
                                ? Colors.orange.shade50
                                : primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOutOfStock
                                ? Icons.error
                                : isLowStock
                                    ? Icons.warning
                                    : Icons.check_circle,
                            size: 12,
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
                              fontSize: 11,
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
                const SizedBox(height: 6),
                Text(
                  'Price: TZS ${MoneyFormatter(amount: double.tryParse(productPrice.toString()) ?? 0).output.withoutFractionDigits}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock Value: TZS ${MoneyFormatter(amount: stockValue).output.withoutFractionDigits}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
