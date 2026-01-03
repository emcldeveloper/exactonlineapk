import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:e_online/pages/inventory/product_inventory_settings_page.dart';
import 'package:e_online/pages/inventory/add_inventory_product_page.dart';
import 'package:intl/intl.dart';
import 'package:e_online/controllers/inventory_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

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
  final TextEditingController _costPerUnitController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedExpiryDate;

  final InventoryController _inventoryController =
      Get.put(InventoryController());
  final ProductController _productController = Get.put(ProductController());

  bool _isLoading = false;
  List<dynamic> _batches = [];
  List<dynamic> _transactions = [];
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  BluetoothCharacteristic? _printerCharacteristic;
  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }

  Future<void> _loadInventoryData() async {
    setState(() => _isLoading = true);
    try {
      final businessId = await SharedPreferencesUtil.getSelectedBusiness();
      final productId = widget.product['id'];

      // Load batches
      final batches = await _inventoryController.getInventoryBatches(
        productId: productId,
        shopId: businessId,
      );

      // Load transactions
      final transactions = await _inventoryController.getInventoryTransactions(
        productId: productId,
        shopId: businessId,
      );

      setState(() {
        _batches = batches;
        _transactions = transactions;
      });
    } catch (e) {
      print('Error loading inventory data: $e');
      Get.snackbar(
        'Error',
        'Failed to load inventory data',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirmation() {
    final productName = widget.product['name'] ?? 'this product';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Delete Product?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "$productName"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will permanently delete all inventory data, batches, and transaction history.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
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
              _deleteProduct();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    try {
      setState(() => _isLoading = true);

      final productId = widget.product['id'];
      final response = await _productController.deleteProduct(productId);

      if (response != null) {
        // Return to home page with result true to trigger refresh
        Get.back(result: true);
        Get.back(result: true);

        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.snackbar(
            'Success',
            'Product deleted successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        });
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete product',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error deleting product: $e');
      Get.snackbar(
        'Error',
        'Failed to delete product: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getTransactionTypeDisplay(String type) {
    switch (type) {
      case 'RESTOCK':
        return 'Restock';
      case 'SALE':
        return 'Sale';
      case 'RETURN':
        return 'Return';
      case 'ADJUSTMENT':
        return 'Adjustment';
      case 'DAMAGED':
        return 'Damaged';
      case 'EXPIRED':
        return 'Expired';
      default:
        return type;
    }
  }

  void _showRestockDialog() {
    _selectedExpiryDate = null;
    // Generate 10-digit batch number with BATCH- prefix
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    _batchNumberController.text =
        'BATCH-${timestamp.substring(timestamp.length - 10)}';
    _restockController.clear();
    _costPerUnitController.clear();
    _locationController.clear();

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
                    labelText: 'Quantity to Add *',
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
                    labelText: 'Batch Number *',
                    hintText: 'Enter batch number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.qr_code),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _costPerUnitController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cost Per Unit',
                    hintText: 'Enter unit cost',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter storage location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
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
              onPressed: () async {
                final quantity = int.tryParse(_restockController.text) ?? 0;
                final costPerUnit =
                    double.tryParse(_costPerUnitController.text);

                if (quantity > 0 && _batchNumberController.text.isNotEmpty) {
                  Navigator.pop(context);

                  setState(() => _isLoading = true);

                  try {
                    final businessId =
                        await SharedPreferencesUtil.getSelectedBusiness();
                    if (businessId == null) {
                      Get.snackbar('Error', 'No business selected');
                      return;
                    }
                    final productId = widget.product['id'];

                    // Add batch
                    final success =
                        await _inventoryController.addInventoryBatch(
                      productId: productId,
                      shopId: businessId,
                      batchNumber: _batchNumberController.text,
                      quantity: quantity,
                      expiryDate: _selectedExpiryDate,
                      costPerUnit: costPerUnit,
                      location: _locationController.text.isEmpty
                          ? null
                          : _locationController.text,
                    );

                    if (success) {
                      // Reload inventory data
                      await _loadInventoryData();

                      Get.snackbar(
                        'Success',
                        'Added $quantity units to inventory',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    }
                  } catch (e) {
                    print('Error adding batch: $e');
                  } finally {
                    setState(() => _isLoading = false);
                  }
                } else {
                  Get.snackbar(
                    'Validation Error',
                    'Please enter quantity and batch number',
                    backgroundColor: Colors.orangeAccent,
                    colorText: Colors.white,
                  );
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

  Future<void> _scanForBluetoothDevices() async {
    try {
      // Request Bluetooth permissions
      if (await Permission.bluetoothConnect.request().isGranted &&
          await Permission.bluetoothScan.request().isGranted) {
        // Check if Bluetooth is on
        if (await FlutterBluePlus.isSupported == false) {
          Get.snackbar(
            'Not Supported',
            'Bluetooth is not supported on this device',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        // Turn on Bluetooth if off
        if (await FlutterBluePlus.adapterState.first !=
            BluetoothAdapterState.on) {
          Get.snackbar(
            'Bluetooth Disabled',
            'Please enable Bluetooth and try again',
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.white,
          );
          return;
        }

        // Get bonded/connected devices
        List<BluetoothDevice> bondedDevices =
            await FlutterBluePlus.bondedDevices;
        List<BluetoothDevice> connectedDevices =
            FlutterBluePlus.connectedDevices;

        setState(() {
          _devices = [...bondedDevices, ...connectedDevices].toSet().toList();
        });

        if (_devices.isEmpty) {
          Get.snackbar(
            'No Devices Found',
            'No paired Bluetooth devices found. Please pair your printer first.',
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Permission Denied',
          'Bluetooth permissions are required to connect to printers',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error scanning for Bluetooth devices: $e');
      Get.snackbar(
        'Error',
        'Failed to scan for Bluetooth devices: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _connectToPrinter(BluetoothDevice device) async {
    try {
      // Disconnect if already connected
      if (device.isConnected) {
        await device.disconnect();
      }

      // Connect to the device
      await device.connect(timeout: const Duration(seconds: 15));

      // Discover services
      List<BluetoothService> services = await device.discoverServices();

      // Find a writable characteristic (usually for Serial Port Profile)
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse) {
            _printerCharacteristic = characteristic;
            break;
          }
        }
        if (_printerCharacteristic != null) break;
      }

      setState(() {
        _selectedDevice = device;
      });

      Get.snackbar(
        'Connected',
        'Successfully connected to ${device.platformName.isNotEmpty ? device.platformName : 'Printer'}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error connecting to printer: $e');
      Get.snackbar(
        'Connection Failed',
        'Failed to connect to printer: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _printBatchBarcode(Map<String, dynamic> batch) async {
    try {
      // Check if connected and characteristic is available
      if (_selectedDevice == null ||
          !_selectedDevice!.isConnected ||
          _printerCharacteristic == null) {
        Get.snackbar(
          'Not Connected',
          'Please connect to a printer first',
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
        return;
      }

      final batchNumber = batch['batchNumber'] as String;
      final expiryDateRaw = batch['expiryDate'];
      final expiryDate = expiryDateRaw != null
          ? (expiryDateRaw is DateTime
              ? expiryDateRaw
              : DateTime.parse(expiryDateRaw.toString()))
          : null;
      final productName = widget.product['name'] ?? 'Unknown Product';
      final productSKU = widget.product['productSKU'] ?? '';
      final productPrice = widget.product['sellingPrice'] ?? 0;
      final quantity = batch['quantity'] ?? 1;

      // Generate batch-specific barcode - use batch number (e.g., BATCH-1234567890)
      final barcodeData = batchNumber;

      // Extract numeric part only (remove "BATCH-" prefix)
      String upcData = barcodeData.replaceAll(RegExp(r'[^0-9]'), '');

      // Don't pad - use the actual batch number as-is
      // UPC-A requires 11 digits + 1 checksum, but we'll use CODE128 format instead
      // which is more flexible and doesn't require padding

      // Print multiple labels based on quantity
      for (int i = 0; i < quantity; i++) {
        // ESC/POS commands for thermal printer (P58H40 compatible)
        List<int> bytes = [];

        // Initialize printer
        bytes.addAll([0x1B, 0x40]); // ESC @ - Initialize

        // Center alignment
        bytes.addAll([0x1B, 0x61, 0x01]); // ESC a 1 - Center alignment

        // Barcode configuration - larger to fill sticker width
        bytes.addAll([0x1D, 0x48, 0x02]); // GS H 2 - HRI below
        bytes.addAll(
            [0x1D, 0x68, 0x50]); // GS h 80 - Height (smaller for sticker)
        bytes.addAll([0x1D, 0x77, 0x03]); // GS w 3 - Width (wider bars)

        // Print CODE128 barcode (type 73, supports variable length)
        bytes.addAll([0x1D, 0x6B, 0x49]); // GS k 73 (CODE128)
        bytes.add(upcData.length); // Length of data
        bytes.addAll(upcData.codeUnits);

        bytes.add(0x0A);

        // Print price in normal size
        bytes.addAll(
            'Price: TZS ${MoneyFormatter(amount: double.tryParse(productPrice.toString()) ?? 0).output.withoutFractionDigits}'
                .codeUnits);
        bytes.add(0x0A);
        bytes.add(0x0A);

        // Cut paper
        bytes.addAll([0x1D, 0x56, 0x00]);

        // Send to printer in chunks (max 512 bytes per write for BLE)
        const chunkSize = 512;
        for (var j = 0; j < bytes.length; j += chunkSize) {
          final end =
              (j + chunkSize < bytes.length) ? j + chunkSize : bytes.length;
          final chunk = bytes.sublist(j, end);
          await _printerCharacteristic!.write(chunk,
              withoutResponse:
                  _printerCharacteristic!.properties.writeWithoutResponse);
          await Future.delayed(
              const Duration(milliseconds: 100)); // Small delay between chunks
        }

        // Delay between labels
        if (i < quantity - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      Get.snackbar(
        'Success',
        'Printed $quantity barcode${quantity > 1 ? 's' : ''} successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error printing: $e');
      Get.snackbar(
        'Printing Failed',
        'Failed to print barcode: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _showPrinterSelectionDialog(Map<String, dynamic> batch) async {
    // First scan for devices
    await _scanForBluetoothDevices();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.print, color: primary),
              const SizedBox(width: 8),
              const Text('Select Printer'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_devices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.bluetooth_disabled,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No paired Bluetooth devices found',
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please pair your printer in Bluetooth settings',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: _devices.map((device) {
                      final isConnected =
                          _selectedDevice?.remoteId == device.remoteId;
                      return ListTile(
                        leading: Icon(
                          Icons.print,
                          color: isConnected ? Colors.green : primary,
                        ),
                        title: Text(device.platformName.isNotEmpty
                            ? device.platformName
                            : 'Unknown Device'),
                        subtitle: Text(device.remoteId.toString()),
                        trailing: isConnected
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : null,
                        onTap: () async {
                          Navigator.pop(context);
                          await _connectToPrinter(device);
                          // After successful connection, print
                          await _printBatchBarcode(batch);
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (_devices.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _scanForBluetoothDevices();
                  if (_devices.isNotEmpty) {
                    _showPrinterSelectionDialog(batch);
                  }
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Refresh',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: primary),
              ),
          ],
        ),
      ),
    );
  }

  void _showBatchBarcodeDialog(Map<String, dynamic> batch) {
    final batchNumber = batch['batchNumber'] as String;
    final expiryDateRaw = batch['expiryDate'];
    final expiryDate = expiryDateRaw != null
        ? (expiryDateRaw is DateTime
            ? expiryDateRaw
            : DateTime.parse(expiryDateRaw.toString()))
        : null;
    final productName = widget.product['name'] ?? 'Unknown Product';
    final productSKU = widget.product['productSKU'] ?? '';

    // Generate batch-specific barcode - use the actual batchNumber (e.g., BATCH-1234567890)
    // This is what will be scanned and used to lookup the product
    final barcodeData = batchNumber;

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
                      // Actual Barcode Widget
                      Container(
                        height: 100,
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        child: BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: barcodeData,
                          drawText: false,
                          color: Colors.black,
                          backgroundColor: Colors.white,
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
              Navigator.pop(context);
              _showPrinterSelectionDialog(batch);
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
              onPressed: () async {
                final shop = widget.product['Shop'];
                if (shop != null) {
                  final result = await Get.to(() => AddInventoryProductPage(
                        shopId: shop['id'],
                        shopName: shop['name'],
                        product: widget.product, // Pass product for editing
                      ));
                  if (result == true) {
                    // Reload data after changes
                    _loadInventoryData();
                  }
                } else {
                  Get.snackbar(
                    'Error',
                    'Shop information not available',
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                }
              },
              tooltip: 'Edit Product',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(),
              tooltip: 'Delete Product',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                final result = await Get.to(() =>
                    ProductInventorySettingsPage(product: widget.product));
                if (result == true) {
                  // Reload inventory data after settings update
                  _loadInventoryData();
                }
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
    return RefreshIndicator(
      onRefresh: _loadInventoryData,
      child: SingleChildScrollView(
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
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _batches.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 32),
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
      ),
    );
  }

  Widget _buildInventoryHistoryTab() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No transaction history',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Transactions will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInventoryData,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                final createdAt = transaction['createdAt'];
                final date = createdAt is DateTime
                    ? createdAt
                    : DateTime.parse(createdAt.toString());
                return _buildHistoryItem(
                  type: transaction['transactionType'] ?? 'UNKNOWN',
                  quantity: transaction['quantityChange'] ?? 0,
                  date: date,
                  note: transaction['notes'] ??
                      transaction['reference'] ??
                      'No description',
                  batchNumber: transaction['batchNumber'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String type,
    required int quantity,
    required DateTime date,
    required String note,
    String? batchNumber,
  }) {
    final isPositive = quantity > 0;
    final typeDisplay = _getTransactionTypeDisplay(type);
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
                    typeDisplay,
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
                  if (batchNumber != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Batch: $batchNumber',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(date),
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
    final expiryDateRaw = batch['expiryDate'];
    final expiryDate = expiryDateRaw != null
        ? (expiryDateRaw is DateTime
            ? expiryDateRaw
            : DateTime.parse(expiryDateRaw.toString()))
        : null;
    final daysUntilExpiry = expiryDate?.difference(DateTime.now()).inDays;
    final quantity = batch['quantity'] ?? 0;
    final batchNumber = batch['batchNumber'] ?? 'N/A';
    final createdAtRaw = batch['createdAt'];
    final dateAdded = createdAtRaw is DateTime
        ? createdAtRaw
        : DateTime.parse(createdAtRaw.toString());

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
    _selectedDevice?.disconnect();
    super.dispose();
  }
}
