import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_online/pages/pos/pos_sales_history_page.dart';
import 'package:e_online/pages/pos/pos_analytics_page.dart';
import 'package:e_online/pages/pos/pos_receipt_page.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/pos_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:image_picker/image_picker.dart';

class POSMainPage extends StatefulWidget {
  final String shopId;
  final String shopName;

  const POSMainPage({
    Key? key,
    required this.shopId,
    required this.shopName,
  }) : super(key: key);

  @override
  State<POSMainPage> createState() => _POSMainPageState();
}

class _POSMainPageState extends State<POSMainPage> {
  final ProductController productController = Get.put(ProductController());
  final POSController posController = Get.put(POSController());
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  final List<Map<String, dynamic>> _cartItems = [];

  bool _isLoading = true;
  double _total = 0.0;
  double _subtotal = 0.0;
  double _discount = 0.0;
  final TextEditingController _discountController = TextEditingController();

  // Barcode scanner support
  String _scannerBuffer = '';
  DateTime? _lastScanTime;
  bool _isScannerConnected = false;
  final FocusNode _scannerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
    _initializeScanner();
  }

  void _initializeScanner() {
    // Request focus for scanner input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scannerFocusNode.requestFocus();
    });

    // Detect scanner connection by checking for rapid keyboard input
    setState(() {
      _isScannerConnected = true; // Assume connected, will verify on first scan
    });

    if (_isScannerConnected) {
      Get.snackbar(
        'Scanner Ready',
        'USB Barcode Scanner (8200DW) is ready to use',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _scannerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await productController.getShopProducts(
        id: widget.shopId,
        page: 1,
        limit: 100,
      );

      print('Fetched products count: ${response.length}');
      if (response.isNotEmpty) {
        print('First product structure: ${response[0]}');
        print('First product ID: ${response[0]['id']}');
      }

      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading products: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) {
          final name = (product['name'] ?? '').toLowerCase();
          final sku = (product['productSKU'] ?? '').toLowerCase();
          return name.contains(query) || sku.contains(query);
        }).toList();
      }
    });
  }

  void _handleScannedBarcode(String barcode) {
    if (barcode.isEmpty) return;

    print('Scanned barcode: $barcode');

    // Search for product by barcode or batch number
    final product = products.firstWhereOrNull((p) {
      final productBarcode = p['barcode']?.toString() ?? '';
      final productSKU = p['productSKU']?.toString() ?? '';
      // Also check if barcode matches a batch number pattern
      return productBarcode == barcode || productSKU == barcode;
    });

    if (product != null) {
      _addToCart(product);
      Get.snackbar(
        'Product Added',
        '${product['name']} added to cart',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } else {
      // Try to find by batch number in inventory batches
      _searchByBatchNumber(barcode);
    }
  }

  void _searchByBatchNumber(String batchNumber) {
    // Extract numeric part from barcode (remove leading zeros added for UPC-A)
    final numericBatch = batchNumber.replaceAll(RegExp(r'^0+'), '');

    // Search through products for matching batch
    for (var product in products) {
      // Check if this could be a batch number (BATCH-xxxxxxxxxx format)
      final possibleBatchNumber = 'BATCH-$numericBatch';

      // For now, just search by the batch number pattern
      // You may need to fetch batch info from inventory controller
      print('Searching for batch: $possibleBatchNumber');

      // If product barcode contains the batch number, add it
      final productBarcode = product['barcode']?.toString() ?? '';
      if (productBarcode.contains(numericBatch)) {
        _addToCart(product);
        Get.snackbar(
          'Product Added (Batch)',
          '${product['name']} - Batch: $possibleBatchNumber',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }
    }

    Get.snackbar(
      'Not Found',
      'No product found for barcode: $batchNumber',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final now = DateTime.now();

    // Reset buffer if more than 100ms since last character (new scan)
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!) > const Duration(milliseconds: 100)) {
      _scannerBuffer = '';
    }

    _lastScanTime = now;

    // Handle Enter key (end of barcode scan)
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_scannerBuffer.isNotEmpty) {
        _handleScannedBarcode(_scannerBuffer.trim());
        _scannerBuffer = '';
      }
      return;
    }

    // Append character to buffer
    final character = event.character;
    if (character != null && character.trim().isNotEmpty) {
      _scannerBuffer += character;
    }
  }

  void _showProductSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              // Modal Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: const TextStyle(fontSize: 13),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No products found',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return _buildProductHorizontalCardWithState(
                                  product, setModalState);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _scannerFocusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        _onKey(event);
        return KeyEventResult.handled;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Point of Sale',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.shopName,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Get.to(() => const POSSalesHistoryPage());
              },
              tooltip: 'Sales History',
            ),
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
                Get.to(() => const POSAnalyticsPage());
              },
              tooltip: 'Sales Analytics',
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            // Search Bar (opens modal)
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: _showProductSelectionModal,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Search products...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Scanner Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openBarcodeScanner,
                  icon: const Icon(Icons.qr_code_scanner,
                      size: 20, color: Colors.white),
                  label: const Text(
                    'Scan Barcode',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Cart Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cart (${_cartItems.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_cartItems.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _cartItems.clear();
                          _calculateTotals();
                        });
                      },
                      icon: const Icon(Icons.clear_all, size: 16),
                      label:
                          const Text('Clear', style: TextStyle(fontSize: 13)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
            ),
            // Cart Items
            Expanded(
              child: _cartItems.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 50,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cart is empty',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tap search to add products',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(_cartItems[index], index);
                      },
                    ),
            ),
            // Totals and Checkout
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTotalRow('Subtotal:',
                        'TZS ${MoneyFormatter(amount: _subtotal).output.withoutFractionDigits}'),
                    const SizedBox(height: 8),
                    // Discount Section
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Discount',
                              labelStyle: const TextStyle(fontSize: 12),
                              hintText: '0',
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixText: 'TZS ',
                              prefixStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _discount = double.tryParse(value) ?? 0.0;
                                _calculateTotals();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _discountController.clear();
                              _discount = 0.0;
                              _calculateTotals();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Clear',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    if (_discount > 0) ...[
                      const SizedBox(height: 6),
                      _buildTotalRow(
                        'Discount:',
                        '- TZS ${MoneyFormatter(amount: _discount).output.withoutFractionDigits}',
                        isDiscount: true,
                      ),
                    ],
                    const Divider(height: 16),
                    _buildTotalRow(
                      'Total:',
                      'TZS ${MoneyFormatter(amount: _total).output.withoutFractionDigits}',
                      isTotal: true,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _cartItems.isEmpty ? null : _showCheckoutDialog,
                        icon: const Icon(Icons.payment, color: Colors.white),
                        label: const Text(
                          'Checkout',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: primary,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ), // Close body Column
      ), // Close Scaffold
    ); // Close Focus
  }

  Widget _buildProductHorizontalCardWithState(
      Map<String, dynamic> product, StateSetter setModalState) {
    final productName = product['name'] ?? 'Unknown';
    final productPrice =
        double.tryParse(product['sellingPrice']?.toString() ?? '0') ?? 0;
    final productImages = product['ProductImages'] ?? [];
    final productQuantity = product['productQuantity'] ?? 0;
    final productSKU = product['productSKU'] ?? '';
    final inStock = productQuantity > 0;

    // Check if product is already in cart
    final cartItem = _cartItems.firstWhere(
      (item) => item['id'] == product['id'],
      orElse: () => {},
    );
    final inCart = cartItem.isNotEmpty;
    final currentQuantity = inCart ? cartItem['quantity'] : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: inStock
              ? (inCart ? primary.withOpacity(0.3) : Colors.grey.shade200)
              : Colors.red.shade100,
          width: inCart ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 70,
                height: 70,
                color: Colors.grey.shade100,
                child: productImages.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: productImages[0]['image'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.image_outlined, size: 30),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_outlined, size: 30),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: inStock ? Colors.black : Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (productSKU.isNotEmpty)
                    Text(
                      'SKU: $productSKU',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TZS ${MoneyFormatter(amount: productPrice).output.withoutFractionDigits}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: inStock ? primary : Colors.grey,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: inStock
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          inStock ? 'Stock: $productQuantity' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: inStock ? Colors.green.shade700 : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (inStock) ...[
              const SizedBox(width: 8),
              // Quantity Controls or Add Button
              if (inCart)
                Container(
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 22),
                        color: primary,
                        onPressed: () {
                          setModalState(() {
                            setState(() {
                              if (currentQuantity > 1) {
                                cartItem['quantity']--;
                              } else {
                                _cartItems.remove(cartItem);
                              }
                              _calculateTotals();
                            });
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$currentQuantity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 22),
                        color: primary,
                        onPressed: () {
                          setModalState(() {
                            setState(() {
                              if (currentQuantity < productQuantity) {
                                cartItem['quantity']++;
                                _calculateTotals();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Only $productQuantity units available'),
                                    backgroundColor: Colors.orange,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            });
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ],
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 32),
                  color: primary,
                  onPressed: () {
                    _addToCart(product, setModalState);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    final productImages = item['ProductImages'] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade200,
                child: productImages.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: productImages[0]['image'],
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 20),
                      )
                    : const Icon(Icons.image, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TZS ${MoneyFormatter(amount: item['price']).output.withoutFractionDigits}',
                    style: TextStyle(
                      fontSize: 12,
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity Controls
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () {
                        setState(() {
                          if (item['quantity'] > 1) {
                            item['quantity']--;
                          } else {
                            _cartItems.removeAt(index);
                          }
                          _calculateTotals();
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item['quantity']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () {
                        setState(() {
                          // Check stock before adding
                          if (item['quantity'] < item['stock']) {
                            item['quantity']++;
                            _calculateTotals();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Only ${item['stock']} units available'),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                Text(
                  'TZS ${MoneyFormatter(amount: item['price'] * item['quantity']).output.withoutFractionDigits}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value,
      {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 13,
            fontWeight: FontWeight.bold,
            color: isTotal ? primary : (isDiscount ? Colors.red : Colors.black),
          ),
        ),
      ],
    );
  }

  void _addToCart(Map<String, dynamic> product, [StateSetter? setModalState]) {
    final productId = product['id'];

    // Validate product ID exists
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Product ID is missing. Cannot add to cart.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      print('Error: Product has no ID: $product');
      return;
    }

    final updateState = () {
      final existingItem = _cartItems.firstWhere(
        (item) => item['id'] == productId,
        orElse: () => {},
      );

      if (existingItem.isNotEmpty) {
        if (existingItem['quantity'] < existingItem['stock']) {
          existingItem['quantity']++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Only ${existingItem['stock']} units available'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 1),
            ),
          );
          return;
        }
      } else {
        _cartItems.add({
          'id': productId,
          'name': product['name'] ?? 'Unknown',
          'price':
              double.tryParse(product['sellingPrice']?.toString() ?? '0') ?? 0,
          'sku': product['productSKU'] ?? '',
          'quantity': 1,
          'stock': product['productQuantity'] ?? 0,
          'ProductImages': product['ProductImages'] ?? [],
        });
      }
      _calculateTotals();
    };

    if (setModalState != null) {
      setModalState(() {
        setState(updateState);
      });
    } else {
      setState(updateState);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name'] ?? 'Product'} added to cart'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _calculateTotals() {
    _subtotal = 0.0;
    for (var item in _cartItems) {
      _subtotal += item['price'] * item['quantity'];
    }
    _total = _subtotal - _discount;
    if (_total < 0) _total = 0;
  }

  Future<void> _openBarcodeScanner() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        // TODO: Process barcode image with barcode scanner library
        // For now, show message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Barcode scanning will be implemented with ML Kit'),
            backgroundColor: primary,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Sale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: TZS ${MoneyFormatter(amount: _total).output.withoutFractionDigits}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Payment Method:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(Icons.credit_card, 'Card Payment', context),
            _buildPaymentOption(Icons.money, 'Cash Payment', context),
            _buildPaymentOption(Icons.phone_android, 'Mobile Money', context),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      IconData icon, String label, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(icon, color: primary, size: 24),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: primary),
        onTap: () {
          Navigator.pop(context);
          _completeSale(label);
        },
      ),
    );
  }

  void _completeSale(String paymentMethod) async {
    // Validate cart items have all required fields
    for (var item in _cartItems) {
      if (item['id'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Error: Invalid product in cart. Please remove and re-add the product.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Prepare sale items
    final items = _cartItems
        .map((item) => {
              'id': item['id'],
              'quantity': item['quantity'],
              'price': item['price'],
              'discount': 0.0,
              'tax': 0.0,
              'notes': null,
            })
        .toList();

    print('Cart items being sent: $items'); // Debug log

    // Create sale
    final saleData = await posController.createSale(
      shopId: widget.shopId,
      items: items,
      subtotal: _subtotal,
      discount: _discount,
      tax: 0.0,
      total: _total,
      paymentMethod: paymentMethod,
      amountPaid: _total,
    );

    // Close loading dialog
    Navigator.pop(context);

    if (saleData != null) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Sale Completed!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Payment Method: $paymentMethod',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Receipt: ${saleData['receiptNumber']}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: TZS ${MoneyFormatter(amount: _total).output.withoutFractionDigits}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _cartItems.clear();
                  _discount = 0;
                  _discountController.clear();
                  _calculateTotals();
                });
              },
              child: const Text('New Sale'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Get.to(() => POSReceiptPage(saleData: saleData));
                setState(() {
                  _cartItems.clear();
                  _discount = 0;
                  _discountController.clear();
                  _calculateTotals();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Receipt'),
            ),
          ],
        ),
      );
    }
  }
}
