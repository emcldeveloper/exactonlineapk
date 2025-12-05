import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QRCodePrintPage extends StatefulWidget {
  final String shopId;

  const QRCodePrintPage({
    Key? key,
    required this.shopId,
  }) : super(key: key);

  @override
  State<QRCodePrintPage> createState() => _QRCodePrintPageState();
}

class _QRCodePrintPageState extends State<QRCodePrintPage> {
  final List<Map<String, dynamic>> _selectedProducts = [];
  String _searchQuery = '';
  List products = [];
  bool _isLoading = true;
  final ProductController productController = ProductController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final res = await productController.getShopProducts(
        id: widget.shopId,
        page: 1,
        limit: 100,
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

  List get filteredProducts {
    if (_searchQuery.isEmpty) return products;
    return products.where((product) {
      final name = product['name']?.toString().toLowerCase() ?? '';
      final sku = product['productSKU']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || sku.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Print Barcodes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedProducts.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                _showPrintPreview();
              },
              icon: const Icon(Icons.print, color: Colors.white),
              label: Text(
                'Print (${_selectedProducts.length})',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products to print barcodes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          // Selected Products Summary
          if (_selectedProducts.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: primary),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedProducts.length} products selected',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedProducts.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Products List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
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
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final productId = product['id'];
                          final productName = product['name'] ?? 'Unknown';
                          final productSKU = product['productSKU'] ?? 'N/A';
                          final productImages = product['ProductImages'] ?? [];
                          final isSelected = _selectedProducts
                              .any((p) => p['id'] == productId);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedProducts.add(product);
                                  } else {
                                    _selectedProducts.removeWhere(
                                      (p) => p['id'] == productId,
                                    );
                                  }
                                });
                              },
                              title: Text(
                                productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('SKU: $productSKU'),
                              secondary: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade200,
                                  child: productImages.isNotEmpty
                                      ? CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: productImages[0]["image"],
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                            Icons.barcode_reader,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.barcode_reader,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectedProducts.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                _showPrintPreview();
              },
              backgroundColor: primary,
              icon: const Icon(Icons.print, color: Colors.white),
              label: const Text('Print Selected',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  void _showPrintPreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Barcodes'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Text(
                'Preview of ${_selectedProducts.length} barcodes',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedProducts.length,
                  itemBuilder: (context, index) {
                    final product = _selectedProducts[index];
                    final productName = product['productName'] ?? 'Unknown';
                    final productSKU = product['productSKU'] ?? 'N/A';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.barcode_reader,
                                size: 40,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            productSKU,
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'Courier',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Barcodes sent to printer'),
                  backgroundColor: primary,
                ),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
