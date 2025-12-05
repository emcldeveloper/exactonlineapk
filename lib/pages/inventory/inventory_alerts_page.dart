import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';

class InventoryAlertsPage extends StatelessWidget {
  const InventoryAlertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory Alerts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showAlertSettings(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Critical',
                  '5',
                  Icons.error,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Warning',
                  '23',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Info',
                  '12',
                  Icons.info,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Alert Types Tabs
          _buildSectionHeader('Critical Alerts', Colors.red),
          const SizedBox(height: 12),
          _buildAlertCard(
            context: context,
            title: 'Out of Stock',
            message: 'Product ABC is out of stock',
            time: '5 minutes ago',
            type: AlertType.critical,
            icon: Icons.remove_shopping_cart,
          ),
          _buildAlertCard(
            context: context,
            title: 'Out of Stock',
            message: 'Product XYZ has 0 units remaining',
            time: '1 hour ago',
            type: AlertType.critical,
            icon: Icons.remove_shopping_cart,
          ),
          _buildAlertCard(
            context: context,
            title: 'Critical Stock Level',
            message: 'Product DEF has only 2 units left',
            time: '2 hours ago',
            type: AlertType.critical,
            icon: Icons.priority_high,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Low Stock Warnings', Colors.orange),
          const SizedBox(height: 12),
          _buildAlertCard(
            context: context,
            title: 'Low Stock',
            message: 'Product GHI below reorder level (8 units)',
            time: '3 hours ago',
            type: AlertType.warning,
            icon: Icons.warning,
          ),
          _buildAlertCard(
            context: context,
            title: 'Low Stock',
            message: 'Product JKL needs reordering (12 units)',
            time: '5 hours ago',
            type: AlertType.warning,
            icon: Icons.warning,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Inventory Updates', Colors.blue),
          const SizedBox(height: 12),
          _buildAlertCard(
            context: context,
            title: 'Stock Received',
            message: '50 units of Product MNO added to inventory',
            time: '1 day ago',
            type: AlertType.info,
            icon: Icons.add_shopping_cart,
          ),
          _buildAlertCard(
            context: context,
            title: 'Inventory Count',
            message: 'Weekly inventory count completed',
            time: '2 days ago',
            type: AlertType.info,
            icon: Icons.checklist,
          ),
          _buildAlertCard(
            context: context,
            title: 'Price Update',
            message: 'Prices updated for 15 products',
            time: '3 days ago',
            type: AlertType.info,
            icon: Icons.attach_money,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required BuildContext context,
    required String title,
    required String message,
    required String time,
    required AlertType type,
    required IconData icon,
  }) {
    Color color;
    switch (type) {
      case AlertType.critical:
        color = Colors.red;
        break;
      case AlertType.warning:
        color = Colors.orange;
        break;
      case AlertType.info:
        color = Colors.blue;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to product details or take action
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  // Dismiss alert
                },
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Out of Stock Alerts'),
                subtitle: const Text('Notify when products are out of stock'),
              ),
              SwitchListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Low Stock Alerts'),
                subtitle: const Text('Notify when below reorder level'),
              ),
              SwitchListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Price Changes'),
                subtitle: const Text('Notify on price updates'),
              ),
              SwitchListTile(
                value: false,
                onChanged: (value) {},
                title: const Text('Daily Summary'),
                subtitle: const Text('Daily inventory report'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Email Notifications'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Push Notifications'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

enum AlertType {
  critical,
  warning,
  info,
}
