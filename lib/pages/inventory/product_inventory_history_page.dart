import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:e_online/pages/inventory/product_inventory_settings_page.dart';
import 'package:intl/intl.dart';

class ProductInventoryHistoryPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductInventoryHistoryPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductInventoryHistoryPage> createState() =>
      _ProductInventoryHistoryPageState();
}

class _ProductInventoryHistoryPageState
    extends State<ProductInventoryHistoryPage> {
  final TextEditingController _restockController = TextEditingController();
  final TextEditingController _batchNumberController = TextEditingController();
  DateTime? _selectedExpiryDate;

  // Demo batches data - replace with API call
  List<Map<String, dynamic>> _batches = [];

  @override
  void initState() {
    super.initState();
    _loadDemoBatches();
  }

  void _loadDemoBatches() {
    // Demo data - replace with actual API call
    _batches = [
      {
        'batchNumber': 'BATCH-001',
        'quantity': 50,
        'expiryDate': DateTime.now().add(const Duration(days: 15)),
        'dateAdded': DateTime.now().subtract(const Duration(days: 10)),
      },
      {
        'batchNumber': 'BATCH-002',
        'quantity': 30,
        'expiryDate': DateTime.now().add(const Duration(days: 45)),
        'dateAdded': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'batchNumber': 'BATCH-003',
        'quantity': 20,
        'expiryDate': DateTime.now().add(const Duration(days: 90)),
        'dateAdded': DateTime.now().subtract(const Duration(days: 2)),
      },
    ];
  }

  void _showRestockDialog() {
    _selectedExpiryDate = null;
    _batchNumberController.text =
        'BATCH-${DateTime.now().millisecondsSinceEpoch}';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Restock Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _restockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity to Add',
                    hintText: 'Enter quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.add_box),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _batchNumberController,
                  decoration: InputDecoration(
                    labelText: 'Batch Number',
                    hintText: 'Enter batch number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.qr_code),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => _selectedExpiryDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Expiry Date (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedExpiryDate != null
                          ? DateFormat('dd MMM yyyy')
                              .format(_selectedExpiryDate!)
                          : 'Tap to select expiry date',
                      style: TextStyle(
                        color: _selectedExpiryDate != null
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Current stock: ${widget.product['productQuantity'] ?? 0}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
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
            ElevatedButton(
              onPressed: () {
                final quantity = int.tryParse(_restockController.text) ?? 0;
                if (quantity > 0 && _batchNumberController.text.isNotEmpty) {
                  // TODO: Call API to restock with batch data
                  // API payload:
                  // {
                  //   'productId': widget.product['id'],
                  //   'quantity': quantity,
                  //   'batchNumber': _batchNumberController.text,
                  //   'expiryDate': _selectedExpiryDate?.toIso8601String(),
                  //   'dateAdded': DateTime.now().toIso8601String(),
                  // }

                  // Add to demo batches
                  this.setState(() {
                    _batches.add({
                      'batchNumber': _batchNumberController.text,
                      'quantity': quantity,
                      'expiryDate': _selectedExpiryDate,
                      'dateAdded': DateTime.now(),
                    });
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $quantity units to inventory'),
                      backgroundColor: primary,
                    ),
                  );
                  Navigator.pop(context);
                  _restockController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Restock'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBatchBarcodeDialog(Map<String, dynamic> batch) {
    final batchNumber = batch['batchNumber'] as String;
    final expiryDate = batch['expiryDate'] as DateTime?;
    final productName = widget.product['name'] ?? 'Unknown Product';
    final productSKU = widget.product['productSKU'] ?? '';

    // Generate batch-specific barcode
    // Format: PRODUCTSKU-BATCHNUMBER-EXPIRYDATE
    final barcodeData = expiryDate != null
        ? '$productSKU-$batchNumber-${DateFormat('ddMMyyyy').format(expiryDate)}'
        : '$productSKU-$batchNumber';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.qr_code_2, color: primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('Batch Barcode')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: $productSKU',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Divider(),
                    Text(
                      'Batch: $batchNumber',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (expiryDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Expiry: ${DateFormat('dd MMM yyyy').format(expiryDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                    Text(
                      'Quantity: ${batch['quantity']} units',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Barcode Display
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // Barcode visualization (placeholder)
                      Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.barcode_reader,
                                  size: 40, color: Colors.grey.shade700),
                              const SizedBox(height: 4),
                              Text(
                                'Barcode Placeholder',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        barcodeData,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Print Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Use this barcode to track this specific batch during sales',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement actual printing
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Printing barcode for $batchNumber...'),
                  backgroundColor: primary,
                ),
              );
            },
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text(
              'Print',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productName = widget.product['name'] ?? 'Unknown Product';
    final productImages = widget.product['ProductImages'] ?? [];
    final productPrice = widget.product['sellingPrice'] ?? 0;
    final productSKU = widget.product['productSKU'] ?? 'N/A';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Product Inventory',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // TODO: Navigate to edit product page
                Get.snackbar(
                  'Edit Product',
                  'Edit product functionality coming soon',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: primary,
                  colorText: Colors.white,
                );
              },
              tooltip: 'Edit Product',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Get.to(() =>
                    ProductInventorySettingsPage(product: widget.product));
              },
              tooltip: 'Inventory Settings',
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(
                icon: Icon(Icons.inventory_2),
                text: 'Stock Batches',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Inventory History',
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Product Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
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
                  const SizedBox(width: 16),
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SKU: $productSKU',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TZS ${MoneyFormatter(amount: double.tryParse(productPrice.toString()) ?? 0).output.withoutFractionDigits}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Tabs Content
            Expanded(
              child: TabBarView(
                children: [
                  // Stock Batches Tab
                  _buildStockBatchesTab(),
                  // Inventory History Tab
                  _buildInventoryHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBatchesTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Stock
          Container(
            padding: const EdgeInsets.all(16),
            color: primary.withOpacity(0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Stock',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.product['productQuantity'] ?? 0} units',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: (widget.product['productQuantity'] ?? 0) == 0
                            ? Colors.red
                            : (widget.product['productQuantity'] ?? 0) < 10
                                ? Colors.orange
                                : primary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showRestockDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Restock',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Batches List
          _batches.isEmpty
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Center(
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
                          'No batches yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Restock" to create your first batch',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _batches.length,
                  itemBuilder: (context, index) {
                    final batch = _batches[index];
                    return _buildBatchCard(batch);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildInventoryHistoryTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // History List (Demo data)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildHistoryItem(
                type: index % 3 == 0 ? 'Restock' : 'Sale',
                quantity: index % 3 == 0 ? 50 : -5,
                date: DateTime.now().subtract(Duration(days: index)),
                note:
                    index % 3 == 0 ? 'Added from supplier' : 'Sold to customer',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String type,
    required int quantity,
    required DateTime date,
    required String note,
  }) {
    final isPositive = quantity > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isPositive ? '+' : ''}$quantity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchCard(Map<String, dynamic> batch) {
    final expiryDate = batch['expiryDate'] as DateTime?;
    final daysUntilExpiry = expiryDate?.difference(DateTime.now()).inDays;
    final quantity = batch['quantity'] as int;
    final batchNumber = batch['batchNumber'] as String;
    final dateAdded = batch['dateAdded'] as DateTime;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            _getExpiryColor(daysUntilExpiry).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory,
                        color: _getExpiryColor(daysUntilExpiry),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batchNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Added: ${DateFormat('dd MMM yyyy').format(dateAdded)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '$quantity units',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
            if (expiryDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getExpiryColor(daysUntilExpiry).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getExpiryColor(daysUntilExpiry).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      daysUntilExpiry != null && daysUntilExpiry < 7
                          ? Icons.warning
                          : Icons.calendar_today,
                      size: 14,
                      color: _getExpiryColor(daysUntilExpiry),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      daysUntilExpiry != null && daysUntilExpiry >= 0
                          ? 'Expires in $daysUntilExpiry days (${DateFormat('dd MMM yyyy').format(expiryDate)})'
                          : 'Expired on ${DateFormat('dd MMM yyyy').format(expiryDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getExpiryColor(daysUntilExpiry),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Generate Barcode Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showBatchBarcodeDialog(batch),
                icon: Icon(Icons.qr_code_2, size: 18, color: primary),
                label: Text(
                  'Generate Barcode',
                  style: TextStyle(color: primary, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primary),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getExpiryColor(int? days) {
    if (days == null) return Colors.grey;
    if (days < 0) return Colors.black87; // Expired
    if (days < 7) return Colors.red; // Critical
    if (days < 30) return Colors.orange; // Warning
    return Colors.green; // Good
  }

  @override
  void dispose() {
    _restockController.dispose();
    _batchNumberController.dispose();
    super.dispose();
  }
}
