import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_online/controllers/inventory_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';

class ProductInventorySettingsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductInventorySettingsPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductInventorySettingsPage> createState() =>
      _ProductInventorySettingsPageState();
}

class _ProductInventorySettingsPageState
    extends State<ProductInventorySettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final InventoryController _inventoryController =
      Get.put(InventoryController());
  final ProductController _productController = Get.put(ProductController());

  late TextEditingController _sellingPriceController;
  late TextEditingController _buyingPriceController;
  late TextEditingController _lowStockAlertController;
  late TextEditingController _reorderLevelController;
  late TextEditingController _maxStockLevelController;
  late TextEditingController _skuController;
  late TextEditingController _barcodeController;
  late TextEditingController _locationController;
  late TextEditingController _supplierController;
  late TextEditingController _leadTimeController;
  bool _trackInventory = true;
  bool _allowBackorder = false;
  bool _enableLowStockAlert = true;
  bool _enableExpiryTracking = false;
  String _stockValuationMethod = 'FIFO';
  bool _isLoading = false;
  Map<String, dynamic>? _inventorySettings;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInventorySettings();
  }

  Future<void> _loadInventorySettings() async {
    setState(() => _isLoading = true);
    try {
      final productId = widget.product['id'];
      final settings =
          await _inventoryController.getInventorySettings(productId);

      if (settings != null) {
        setState(() {
          _inventorySettings = settings;
          _trackInventory = settings['trackInventory'] ?? true;
          _allowBackorder = settings['allowBackorder'] ?? false;
          _enableLowStockAlert = settings['enableLowStockAlert'] ?? true;
          _enableExpiryTracking = settings['enableExpiryTracking'] ?? false;
          _stockValuationMethod = settings['stockValuationMethod'] ?? 'FIFO';

          _lowStockAlertController.text =
              settings['lowStockThreshold']?.toString() ?? '10';
          _reorderLevelController.text =
              settings['reorderLevel']?.toString() ?? '15';
          _maxStockLevelController.text =
              settings['maxStockLevel']?.toString() ?? '100';
          _locationController.text = settings['location'] ?? '';
          _supplierController.text = settings['supplier'] ?? '';
          _leadTimeController.text =
              settings['leadTimeDays']?.toString() ?? '7';
          _buyingPriceController.text =
              settings['buyingPrice']?.toString() ?? '';
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeControllers() {
    _sellingPriceController = TextEditingController(
      text: widget.product['sellingPrice']?.toString() ?? '',
    );
    _buyingPriceController = TextEditingController(
      text: widget.product['buyingPrice']?.toString() ?? '',
    );
    _lowStockAlertController = TextEditingController(text: '10');
    _reorderLevelController = TextEditingController(text: '15');
    _maxStockLevelController = TextEditingController(text: '100');
    _skuController = TextEditingController(
      text: widget.product['productSKU']?.toString() ?? '',
    );
    _barcodeController = TextEditingController(
      text: widget.product['barcode']?.toString() ?? '',
    );
    _locationController = TextEditingController(text: '');
    _supplierController = TextEditingController(text: '');
    _leadTimeController = TextEditingController(text: '7');
  }

  @override
  void dispose() {
    _sellingPriceController.dispose();
    _buyingPriceController.dispose();
    _lowStockAlertController.dispose();
    _reorderLevelController.dispose();
    _maxStockLevelController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _locationController.dispose();
    _supplierController.dispose();
    _leadTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productId = widget.product['id'];

      // Update product basic info (price, SKU)
      await _productController.editProduct(productId, {
        'sellingPrice': _sellingPriceController.text.trim(),
        'productSKU': _skuController.text.trim(),
      });

      // Update inventory settings
      final success = await _inventoryController.updateInventorySettings(
        productId: productId,
        trackInventory: _trackInventory,
        lowStockThreshold: int.tryParse(_lowStockAlertController.text),
        reorderLevel: int.tryParse(_reorderLevelController.text),
        maxStockLevel: int.tryParse(_maxStockLevelController.text),
        allowBackorder: _allowBackorder,
        enableLowStockAlert: _enableLowStockAlert,
        enableExpiryTracking: _enableExpiryTracking,
        stockValuationMethod: _stockValuationMethod,
        sku: _skuController.text.trim(),
        barcode: _barcodeController.text.trim(),
        location: _locationController.text.trim(),
        supplier: _supplierController.text.trim(),
        leadTimeDays: int.tryParse(_leadTimeController.text),
        buyingPrice: double.tryParse(_buyingPriceController.text),
      );

      if (success) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Settings saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error saving settings: $e');
      Get.snackbar(
        'Error',
        'Failed to save settings',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productName = widget.product['name'] ?? 'Unknown Product';
    final productImages = widget.product['ProductImages'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveSettings,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Header
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: productImages.isNotEmpty
                        ? CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: productImages[0]["image"],
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
                  child: Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pricing Section
            _buildSectionHeader('Pricing', Icons.attach_money),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _sellingPriceController,
                    label: 'Selling Price',
                    hint: '0.00',
                    prefixText: 'TZS ',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _buyingPriceController,
                    label: 'Buying/Cost Price',
                    hint: '0.00',
                    prefixText: 'TZS ',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Profit Margin: ${_calculateProfitMargin()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stock Alert Settings
            _buildSectionHeader('Stock Alert Settings', Icons.notifications),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _enableLowStockAlert,
              onChanged: (value) {
                setState(() {
                  _enableLowStockAlert = value;
                });
              },
              title: const Text('Enable Low Stock Alerts'),
              subtitle: const Text('Get notified when stock is low'),
              activeColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _lowStockAlertController,
                    label: 'Low Stock Alert Level',
                    hint: '10',
                    keyboardType: TextInputType.number,
                    enabled: _enableLowStockAlert,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _reorderLevelController,
                    label: 'Reorder Level',
                    hint: '15',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _maxStockLevelController,
              label: 'Maximum Stock Level',
              hint: '100',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Product Identification
            _buildSectionHeader('Product Identification', Icons.qr_code),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _skuController,
              label: 'SKU (Stock Keeping Unit)',
              hint: 'Enter SKU',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _barcodeController,
              label: 'Barcode/UPC',
              hint: 'Enter barcode',
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () async {
                  // Open camera to scan barcode
                  final ImagePicker picker = ImagePicker();
                  try {
                    final XFile? photo = await picker.pickImage(
                      source: ImageSource.camera,
                      preferredCameraDevice: CameraDevice.rear,
                    );

                    if (photo != null) {
                      // TODO: Process barcode image with barcode scanner library
                      // For now, show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Image captured. Barcode scanning will be implemented.'),
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
                },
              ),
            ),
            const SizedBox(height: 24),

            // Inventory Tracking
            _buildSectionHeader('Inventory Tracking', Icons.inventory),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _trackInventory,
              onChanged: (value) {
                setState(() {
                  _trackInventory = value;
                });
              },
              title: const Text('Track Inventory'),
              subtitle: const Text('Monitor stock levels for this product'),
              activeColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _allowBackorder,
              onChanged: (value) {
                setState(() {
                  _allowBackorder = value;
                });
              },
              title: const Text('Allow Backorders'),
              subtitle: const Text('Accept orders when out of stock'),
              activeColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _enableExpiryTracking,
              onChanged: (value) {
                setState(() {
                  _enableExpiryTracking = value;
                });
              },
              title: const Text('Track Expiry Dates'),
              subtitle: const Text('Monitor product expiration'),
              activeColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 24),

            // Stock Valuation
            _buildSectionHeader(
                'Stock Valuation Method', Icons.account_balance),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _stockValuationMethod,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'FIFO', child: Text('FIFO (First In, First Out)')),
                DropdownMenuItem(
                    value: 'LIFO', child: Text('LIFO (Last In, First Out)')),
                DropdownMenuItem(
                    value: 'WAC', child: Text('Weighted Average Cost')),
                DropdownMenuItem(
                    value: 'Standard', child: Text('Standard Cost')),
              ],
              onChanged: (value) {
                setState(() {
                  _stockValuationMethod = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Storage & Supplier
            _buildSectionHeader('Storage & Supplier', Icons.warehouse),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _locationController,
              label: 'Storage Location',
              hint: 'e.g., Warehouse A, Shelf 3',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _supplierController,
              label: 'Preferred Supplier',
              hint: 'Enter supplier name',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _leadTimeController,
              label: 'Lead Time (days)',
              hint: '7',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: validator,
    );
  }

  String _calculateProfitMargin() {
    final selling = double.tryParse(_sellingPriceController.text) ?? 0;
    final buying = double.tryParse(_buyingPriceController.text) ?? 0;
    if (selling == 0 || buying == 0) return '0.00';
    final margin = ((selling - buying) / selling) * 100;
    return margin.toStringAsFixed(2);
  }
}
