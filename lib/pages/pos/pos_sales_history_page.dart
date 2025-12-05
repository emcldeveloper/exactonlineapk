import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/pos_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';

class POSSalesHistoryPage extends StatefulWidget {
  const POSSalesHistoryPage({Key? key}) : super(key: key);

  @override
  State<POSSalesHistoryPage> createState() => _POSSalesHistoryPageState();
}

class _POSSalesHistoryPageState extends State<POSSalesHistoryPage> {
  final POSController posController = Get.put(POSController());
  final UserController userController = Get.find();
  String _selectedFilter = 'All';
  String? shopId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    shopId = await SharedPreferencesUtil.getCurrentShopId(
        userController.user.value["Shops"] ?? []);
    if (shopId != null) {
      await posController.getSales(shopId: shopId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: primary.withOpacity(0.06),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Today\'s Sales',
                    'TZS 2,450,500',
                    Icons.today,
                    primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Transactions',
                    '48',
                    Icons.receipt_long,
                    primary,
                  ),
                ),
              ],
            ),
          ),
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Today'),
                  _buildFilterChip('This Week'),
                  _buildFilterChip('This Month'),
                  _buildFilterChip('Refunded'),
                ],
              ),
            ),
          ),
          // Sales List
          Expanded(
            child: Obx(() {
              if (posController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (posController.sales.isEmpty) {
                return const Center(
                  child: Text('No sales found'),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: posController.sales.length,
                  itemBuilder: (context, index) {
                    final sale = posController.sales[index];
                    return _buildSaleCard(
                      receiptNumber: sale['receiptNumber'] ?? 'N/A',
                      date: DateTime.parse(sale['createdAt']),
                      items: (sale['items'] as List?)?.length ?? 0,
                      total: (sale['total'] ?? 0).toDouble(),
                      paymentMethod: sale['paymentMethod']
                              ?.toString()
                              .replaceAll('_', ' ') ??
                          'CASH',
                      cashier: sale['cashier']?['fullName'] ?? 'Unknown',
                      isRefunded: sale['status'] == 'REFUNDED',
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: primary.withOpacity(0.12),
        checkmarkColor: primary,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? primary : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildSaleCard({
    required String receiptNumber,
    required DateTime date,
    required int items,
    required double total,
    required String paymentMethod,
    required String cashier,
    bool isRefunded = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRefunded
            ? BorderSide(color: Colors.red.shade200, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          _showSaleDetails(receiptNumber);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          receiptNumber,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                      if (isRefunded) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'REFUNDED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'TZS ${(total * 1000).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isRefunded ? Colors.red : primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 13, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${date.toString().substring(0, 16)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.shopping_bag,
                      size: 13, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '$items items',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    paymentMethod == 'Card'
                        ? Icons.credit_card
                        : paymentMethod == 'Cash'
                            ? Icons.money
                            : Icons.account_balance_wallet,
                    size: 13,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    paymentMethod,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.person, size: 13, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    cashier,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        size: 20, color: Colors.grey.shade600),
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          _showSaleDetails(receiptNumber);
                          break;
                        case 'print':
                          _printReceipt(receiptNumber);
                          break;
                        case 'refund':
                          _showRefundDialog(receiptNumber);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 18),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'print',
                        child: Row(
                          children: [
                            Icon(Icons.print, size: 18),
                            SizedBox(width: 8),
                            Text('Print Receipt'),
                          ],
                        ),
                      ),
                      if (!isRefunded)
                        const PopupMenuItem(
                          value: 'refund',
                          child: Row(
                            children: [
                              Icon(Icons.undo, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Refund',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Sales'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Receipt Number',
                hintText: 'RCP-10001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Date Range',
                hintText: 'Select date range',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.date_range),
              ),
              readOnly: true,
              onTap: () {
                // Show date picker
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Sales'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Card Payments'),
              ),
              CheckboxListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Cash Payments'),
              ),
              CheckboxListTile(
                value: false,
                onChanged: (value) {},
                title: const Text('Mobile Payments'),
              ),
              const Divider(),
              CheckboxListTile(
                value: false,
                onChanged: (value) {},
                title: const Text('Show Refunded Only'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSaleDetails(String receiptNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sale Details - $receiptNumber'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Items:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDetailItem('Product A', 2, 29.99),
              _buildDetailItem('Product B', 1, 49.99),
              const Divider(),
              _buildDetailRow('Subtotal:', 'TZS 109,970'),
              _buildDetailRow('Discount:', 'TZS 0'),
              const SizedBox(height: 8),
              _buildDetailRow('Total:', 'TZS 109,970', isBold: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _printReceipt(receiptNumber);
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String name, int quantity, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$name x$quantity', style: const TextStyle(fontSize: 12)),
          Text('TZS ${((price * quantity) * 1000).toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isBold ? 14 : 12,
              color: isBold ? primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _printReceipt(String receiptNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing receipt $receiptNumber'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showRefundDialog(String receiptNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refund Sale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, size: 60, color: Colors.orange),
            const SizedBox(height: 16),
            Text('Are you sure you want to refund $receiptNumber?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason for refund',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sale $receiptNumber refunded successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Refund'),
          ),
        ],
      ),
    );
  }
}
