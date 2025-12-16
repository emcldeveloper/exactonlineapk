import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/inventory_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class InventoryAlertsPage extends StatefulWidget {
  const InventoryAlertsPage({Key? key}) : super(key: key);

  @override
  State<InventoryAlertsPage> createState() => _InventoryAlertsPageState();
}

class _InventoryAlertsPageState extends State<InventoryAlertsPage> {
  final InventoryController _inventoryController =
      Get.put(InventoryController());
  bool _isLoading = false;
  List<dynamic> _alerts = [];
  Map<String, List<dynamic>> _groupedAlerts = {
    'CRITICAL': [],
    'WARNING': [],
    'INFO': [],
  };

  // Alert preferences
  bool _enableOutOfStockAlerts = true;
  bool _enableLowStockAlerts = true;
  bool _enablePriceChangeAlerts = true;
  bool _enableDailySummary = false;
  bool _enableEmailNotifications = false;
  bool _enablePushNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadAlertPreferences();
    _loadAlerts();
  }

  Future<void> _loadAlertPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _enableOutOfStockAlerts = prefs.getBool('alert_out_of_stock') ?? true;
        _enableLowStockAlerts = prefs.getBool('alert_low_stock') ?? true;
        _enablePriceChangeAlerts = prefs.getBool('alert_price_change') ?? true;
        _enableDailySummary = prefs.getBool('alert_daily_summary') ?? false;
        _enableEmailNotifications = prefs.getBool('alert_email') ?? false;
        _enablePushNotifications = prefs.getBool('alert_push') ?? true;
      });
    } catch (e) {
      print('Error loading alert preferences: $e');
    }
  }

  Future<void> _saveAlertPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('alert_out_of_stock', _enableOutOfStockAlerts);
      await prefs.setBool('alert_low_stock', _enableLowStockAlerts);
      await prefs.setBool('alert_price_change', _enablePriceChangeAlerts);
      await prefs.setBool('alert_daily_summary', _enableDailySummary);
      await prefs.setBool('alert_email', _enableEmailNotifications);
      await prefs.setBool('alert_push', _enablePushNotifications);

      Get.snackbar(
        'Success',
        'Alert preferences saved',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error saving alert preferences: $e');
      Get.snackbar(
        'Error',
        'Failed to save preferences',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      final businessId = await SharedPreferencesUtil.getSelectedBusiness();
      if (businessId != null) {
        final alerts = await _inventoryController.getInventoryAlerts(
          shopId: businessId,
          isResolved: false, // Only show unresolved alerts
        );

        setState(() {
          _alerts = alerts;
          // Group alerts by severity
          _groupedAlerts = {
            'CRITICAL':
                alerts.where((a) => a['severity'] == 'CRITICAL').toList(),
            'WARNING': alerts.where((a) => a['severity'] == 'WARNING').toList(),
            'INFO': alerts.where((a) => a['severity'] == 'INFO').toList(),
          };
        });
      }
    } catch (e) {
      print('Error loading alerts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _dismissAlert(String alertId) async {
    try {
      final success = await _inventoryController.updateInventoryAlert(
        alertId: alertId,
        isResolved: true,
      );

      if (success) {
        _loadAlerts(); // Reload alerts
      }
    } catch (e) {
      print('Error dismissing alert: $e');
    }
  }

  String _getTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date);
    } catch (e) {
      return dateString;
    }
  }

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
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showAlertSettings(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAlerts,
              child: _alerts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Active Alerts',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All your inventory is in good shape!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Critical',
                                _groupedAlerts['CRITICAL']!.length.toString(),
                                Icons.error,
                                Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                'Warning',
                                _groupedAlerts['WARNING']!.length.toString(),
                                Icons.warning,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                'Info',
                                _groupedAlerts['INFO']!.length.toString(),
                                Icons.info,
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Critical Alerts
                        if (_groupedAlerts['CRITICAL']!.isNotEmpty) ...[
                          _buildSectionHeader('Critical Alerts', Colors.red),
                          const SizedBox(height: 12),
                          ..._groupedAlerts['CRITICAL']!
                              .map((alert) => _buildAlertCard(
                                    context: context,
                                    alert: alert,
                                    type: AlertType.critical,
                                  )),
                          const SizedBox(height: 24),
                        ],
                        // Warning Alerts
                        if (_groupedAlerts['WARNING']!.isNotEmpty) ...[
                          _buildSectionHeader(
                              'Low Stock Warnings', Colors.orange),
                          const SizedBox(height: 12),
                          ..._groupedAlerts['WARNING']!
                              .map((alert) => _buildAlertCard(
                                    context: context,
                                    alert: alert,
                                    type: AlertType.warning,
                                  )),
                          const SizedBox(height: 24),
                        ],
                        // Info Alerts
                        if (_groupedAlerts['INFO']!.isNotEmpty) ...[
                          _buildSectionHeader('Inventory Updates', Colors.blue),
                          const SizedBox(height: 12),
                          ..._groupedAlerts['INFO']!
                              .map((alert) => _buildAlertCard(
                                    context: context,
                                    alert: alert,
                                    type: AlertType.info,
                                  )),
                        ],
                      ],
                    ),
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
    required Map<String, dynamic> alert,
    required AlertType type,
  }) {
    final alertType = alert['alertType'] ?? '';
    final message = alert['message'] ?? '';
    final createdAt = alert['createdAt'] ?? '';
    final productName = alert['product']?['name'] ?? 'Unknown Product';

    // Determine icon based on alert type
    IconData icon;
    switch (alertType) {
      case 'OUT_OF_STOCK':
        icon = Icons.remove_shopping_cart;
        break;
      case 'LOW_STOCK':
        icon = Icons.warning;
        break;
      case 'REORDER_LEVEL':
        icon = Icons.priority_high;
        break;
      case 'EXPIRING_SOON':
        icon = Icons.access_time;
        break;
      case 'EXPIRED':
        icon = Icons.dangerous;
        break;
      default:
        icon = Icons.info;
    }

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
          // Could navigate to product details
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
                      productName,
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
                      _getTimeAgo(createdAt),
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
                  _dismissAlert(alert['id']);
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
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.settings, color: primary),
              const SizedBox(width: 8),
              const Text('Alert Settings'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alert Types',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _enableOutOfStockAlerts,
                  onChanged: (value) {
                    setDialogState(() {
                      setState(() {
                        _enableOutOfStockAlerts = value;
                      });
                    });
                  },
                  title: const Text('Out of Stock Alerts'),
                  subtitle: const Text('Notify when products are out of stock'),
                  activeColor: primary,
                ),
                SwitchListTile(
                  value: _enableLowStockAlerts,
                  onChanged: (value) {
                    setDialogState(() {
                      setState(() {
                        _enableLowStockAlerts = value;
                      });
                    });
                  },
                  title: const Text('Low Stock Alerts'),
                  subtitle: const Text('Notify when below reorder level'),
                  activeColor: primary,
                ),
                SwitchListTile(
                  value: _enablePriceChangeAlerts,
                  onChanged: (value) {
                    setDialogState(() {
                      setState(() {
                        _enablePriceChangeAlerts = value;
                      });
                    });
                  },
                  title: const Text('Price Changes'),
                  subtitle: const Text('Notify on price updates'),
                  activeColor: primary,
                ),
                SwitchListTile(
                  value: _enableDailySummary,
                  onChanged: (value) {
                    setDialogState(() {
                      setState(() {
                        _enableDailySummary = value;
                      });
                    });
                  },
                  title: const Text('Daily Summary'),
                  subtitle: const Text('Daily inventory report'),
                  activeColor: primary,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Notification Channels',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _enableEmailNotifications,
                  onChanged: (value) {
                    setDialogState(() {
                      setState(() {
                        _enableEmailNotifications = value;
                      });
                    });
                  },
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive alerts via email'),
                  activeColor: primary,
                ),
                SwitchListTile(
                  value: _enablePushNotifications,
                  onChanged: (value) {
                    setDialogState(() {
                      setState(() {
                        _enablePushNotifications = value;
                      });
                    });
                  },
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive alerts in-app'),
                  activeColor: primary,
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
                _saveAlertPreferences();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

enum AlertType {
  critical,
  warning,
  info,
}
