import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:money_formatter/money_formatter.dart';

class POSReceiptPage extends StatelessWidget {
  final Map<String, dynamic>? saleData;

  const POSReceiptPage({Key? key, this.saleData}) : super(key: key);

  String _formatMoney(double amount) {
    MoneyFormatter fmf = MoneyFormatter(
      amount: amount,
      settings: MoneyFormatterSettings(
        symbol: 'TZS',
        thousandSeparator: ',',
        decimalSeparator: '.',
        symbolAndNumberSeparator: ' ',
      ),
    );
    return fmf.output.symbolOnLeft;
  }

  @override
  Widget build(BuildContext context) {
    // Use provided sale data or fallback to dummy data
    final receiptData = saleData ??
        {
          'receiptNumber': 'RCP-${DateTime.now().millisecondsSinceEpoch}',
          'items': [
            {
              'productName': 'Product 1',
              'unitPrice': 29990,
              'quantity': 2,
              'productSKU': 'SKU-1001',
              'total': 59980
            },
            {
              'productName': 'Product 2',
              'unitPrice': 49990,
              'quantity': 1,
              'productSKU': 'SKU-1002',
              'total': 49990
            },
          ],
          'subtotal': 109970,
          'discount': 0,
          'tax': 0,
          'total': 109970,
          'paymentMethod': 'CASH',
          'cashier': {'fullName': 'Cashier'},
          'createdAt': DateTime.now().toIso8601String(),
        };

    final items = saleData != null
        ? (saleData!['items'] as List?) ?? []
        : receiptData['items'] as List;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: () {
              _showEmailDialog(context);
            },
            tooltip: 'Email Receipt',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Store Info
                      Icon(
                        Icons.receipt_long,
                        size: 50,
                        color: primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ExactOnline',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '123 Business Street',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Tel: (555) 123-4567',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Transaction Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Receipt #${receiptData['receiptNumber']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            DateTime.parse(receiptData['createdAt'])
                                .toString()
                                .substring(0, 16),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Cashier: ${receiptData['cashier']?['fullName'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 11)),
                          Text(
                            'Payment: ${receiptData['paymentMethod']?.toString().replaceAll('_', ' ') ?? 'CASH'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Items
                      ...List.generate(
                        items.length,
                        (index) {
                          final item = items[index];
                          final itemName =
                              item['productName'] ?? item['name'] ?? 'Unknown';
                          final itemPrice =
                              (item['unitPrice'] ?? item['price'] ?? 0)
                                  .toDouble();
                          final itemQty = item['quantity'] ?? 1;
                          final itemTotal =
                              (item['total'] ?? (itemPrice * itemQty))
                                  .toDouble();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        itemName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'TZS ${MoneyFormatter(amount: itemTotal).output.withoutFractionDigits}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      '${item['quantity']} x \$${item['price'].toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item['sku'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Totals
                      _buildTotalRow('Subtotal',
                          _formatMoney(receiptData['subtotal'].toDouble())),
                      const SizedBox(height: 8),
                      if (receiptData['tax'] != null && receiptData['tax'] > 0)
                        _buildTotalRow(
                            'Tax', _formatMoney(receiptData['tax'].toDouble())),
                      if (receiptData['tax'] != null && receiptData['tax'] > 0)
                        const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildTotalRow(
                          'TOTAL',
                          _formatMoney(receiptData['total'].toDouble()),
                          isTotal: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // QR Code
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.qr_code_2,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Scan for digital receipt',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Thank you for your business!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Visit us at www.exactonline.com',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to POS'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _printReceipt(context);
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _printReceipt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.print, color: primary),
            const SizedBox(width: 8),
            const Text('Print Receipt'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Sending to printer...'),
            const SizedBox(height: 16),
            Text(
              'Default POS Printer',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt sent to printer successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showEmailDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Receipt'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            hintText: 'customer@example.com',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
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
                  content: Text('Receipt sent to ${emailController.text}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
