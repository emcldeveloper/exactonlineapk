import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';

class InventoryCountPage extends StatefulWidget {
  const InventoryCountPage({Key? key}) : super(key: key);

  @override
  State<InventoryCountPage> createState() => _InventoryCountPageState();
}

class _InventoryCountPageState extends State<InventoryCountPage> {
  final Map<String, int> _countedProducts = {};
  bool _isCountMode = false;

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
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // Open scanner
            },
            tooltip: 'Scan Product',
          ),
          if (_countedProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                _saveCount();
              },
              tooltip: 'Save Count',
            ),
        ],
      ),
      body: Column(
        children: [
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
                        '3',
                        Icons.warning,
                        primary,
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 20,
              itemBuilder: (context, index) {
                final productId = 'product_$index';
                final productName = 'Product ${index + 1}';
                final sku = 'SKU-${1000 + index}';
                final systemStock = 50 - index;
                final countedStock = _countedProducts[productId] ?? 0;
                final hasCounted = _countedProducts.containsKey(productId);
                final hasDiscrepancy =
                    hasCounted && countedStock != systemStock;

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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.inventory_2,
                                color: Colors.grey.shade400,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Counted',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle),
                                        onPressed: hasCounted &&
                                                countedStock > 0
                                            ? () {
                                                setState(() {
                                                  _countedProducts[productId] =
                                                      countedStock - 1;
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
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade600,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle),
                                        onPressed: () {
                                          setState(() {
                                            _countedProducts[productId] =
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
                                crossAxisAlignment: CrossAxisAlignment.end,
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
      floatingActionButton: _countedProducts.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                _saveCount();
              },
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

  void _saveCount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Inventory Count'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Save count for ${_countedProducts.length} products?'),
            const SizedBox(height: 8),
            const Text(
              'This will update the system stock levels.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
                const SnackBar(
                  content: Text('Inventory count saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                _countedProducts.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
