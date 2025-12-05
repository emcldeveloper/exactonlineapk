import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/categories_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/product_image_controller.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;

class AddInventoryProductPage extends StatefulWidget {
  final String shopId;
  final String shopName;

  const AddInventoryProductPage({
    Key? key,
    required this.shopId,
    required this.shopName,
  }) : super(key: key);

  @override
  State<AddInventoryProductPage> createState() =>
      _AddInventoryProductPageState();
}

class _AddInventoryProductPageState extends State<AddInventoryProductPage> {
  int _currentStep = 0; // 0 for Product Info, 1 for Inventory Settings
  final _formKey = GlobalKey<FormState>();
  final _inventoryFormKey = GlobalKey<FormState>();

  // Image handling
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  // Basic product info controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subcategoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _unitController =
      TextEditingController(text: "Piece");
  final TextEditingController _measurementUnitController =
      TextEditingController(text: "Single/Unit");
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _deliveryScopeController =
      TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _customUnitController =
      TextEditingController(text: "No Unit");

  // Inventory specific controllers
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _buyingPriceController = TextEditingController();
  final TextEditingController _initialStockController = TextEditingController();
  final TextEditingController _lowStockAlertController =
      TextEditingController(text: '10');
  final TextEditingController _reorderLevelController =
      TextEditingController(text: '15');
  final TextEditingController _maxStockLevelController =
      TextEditingController(text: '100');
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();

  // State variables
  bool _trackInventory = true;
  bool _allowBackorder = false;
  bool _enableLowStockAlert = true;
  String _stockValuationMethod = 'FIFO';
  bool _loading = false;
  Rx<bool> priceIncludeDelivery = true.obs;
  Rx<bool> isHidden = false.obs;
  Rx<bool> isNegotiable = true.obs;

  Rx<List<dynamic>> categories = Rx<List<dynamic>>([]);
  Rx<List<dynamic>> subcategories = Rx<List<dynamic>>([]);
  Rx<List<dynamic>> categorySpecifications = Rx<List<dynamic>>([]);
  Rx<Map<String, String>> customSpecifications = Rx<Map<String, String>>({});
  Map<String, TextEditingController> specificationControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _measurementUnitController.dispose();
    _linkController.dispose();
    _deliveryScopeController.dispose();
    _labelController.dispose();
    _valueController.dispose();
    _customUnitController.dispose();
    _sellingPriceController.dispose();
    _buyingPriceController.dispose();
    _initialStockController.dispose();
    _lowStockAlertController.dispose();
    _reorderLevelController.dispose();
    _maxStockLevelController.dispose();
    _skuController.dispose();
    _locationController.dispose();
    _supplierController.dispose();
    for (var controller in specificationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      CategoriesController categoriesController =
          Get.put(CategoriesController());
      final response = await categoriesController.getCategories(
        page: 1,
        limit: 100,
        keyword: '',
        type: '',
      );
      setState(() {
        categories.value = response ?? [];
        if (response != null && response.isNotEmpty) {
          _categoryController.text = response[0]["id"].toString();
          categorySpecifications.value =
              response[0]["CategoryProductSpecifications"] ?? [];
          subcategories.value = response[0]["Subcategories"] ?? [];
          _subcategoryController.text = "";

          // Initialize specification values
          for (var spec in categorySpecifications.value) {
            final specId = spec["id"] ?? spec["label"];
            if (spec["inputStyle"] == "multi-select") {
              spec["value"] = <String>[];
            } else if (spec["inputStyle"] == "toggle") {
              spec["value"] = false;
            } else if (spec["inputStyle"] == "range") {
              spec["value"] = 0.0;
            } else {
              spec["value"] = "";
            }
            if (spec["inputStyle"] == "single-select") {
              specificationControllers[specId] =
                  TextEditingController(text: "");
            }
          }
        }
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load categories",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() {
          _images.addAll(selectedImages);
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Error picking images",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> _pickSingleImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _images.add(pickedFile);
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Error picking image",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  String _calculateProfitMargin() {
    final selling = double.tryParse(_sellingPriceController.text) ?? 0;
    final buying = double.tryParse(_buyingPriceController.text) ?? 0;
    if (buying == 0) return '0.00';
    return (((selling - buying) / buying) * 100).toStringAsFixed(2);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }
    if (!_inventoryFormKey.currentState!.validate()) {
      setState(() => _currentStep = 1);
      return;
    }
    if (_images.isEmpty) {
      Get.snackbar(
        "Error",
        "Please add at least one product image",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      setState(() => _currentStep = 0);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final businessId = await SharedPreferencesUtil.getSelectedBusiness();
      ProductController productController = Get.put(ProductController());
      ProductImageController productImageController =
          Get.put(ProductImageController());

      // Combine category and custom specifications
      Map<String, dynamic> combinedSpecifications = {
        ...{
          for (var item in categorySpecifications.value)
            item["label"]: _formatSpecificationValue(item)
        },
        ...customSpecifications.value,
      };

      // Create product payload
      final productPayload = {
        "name": _nameController.text.trim(),
        "CategoryId": _categoryController.text,
        "SubcategoryId": _subcategoryController.text.isEmpty
            ? null
            : _subcategoryController.text,
        "ShopId": businessId,
        "productPrice": _sellingPriceController.text,
        "buyingPrice": _buyingPriceController.text,
        "description": _descriptionController.text.trim(),
        "unit": _unitController.text,
        "measurementUnit": _measurementUnitController.text,
        "productSKU": _skuController.text.trim(),
        "productQuantity": _initialStockController.text,
        "lowStockAlert": _lowStockAlertController.text,
        "reorderLevel": _reorderLevelController.text,
        "maxStockLevel": _maxStockLevelController.text,
        "trackInventory": _trackInventory.toString(),
        "allowBackorder": _allowBackorder.toString(),
        "enableLowStockAlert": _enableLowStockAlert.toString(),
        "stockValuationMethod": _stockValuationMethod,
        "location": _locationController.text.trim(),
        "supplier": _supplierController.text.trim(),
        "productLink": _linkController.text.trim(),
        "priceIncludeDelivery": priceIncludeDelivery.value,
        "deliveryScope": _deliveryScopeController.text.trim(),
        "isHidden": isHidden.value,
        "isNegotiable": isNegotiable.value,
        "specifications": combinedSpecifications,
      };

      final productResponse =
          await productController.addProduct(productPayload);

      if (productResponse != null) {
        final productId = productResponse["body"]["id"];

        // Upload images
        for (var image in _images) {
          dio.FormData formData = dio.FormData.fromMap({
            "ProductId": productId,
            "image": await dio.MultipartFile.fromFile(
              image.path,
              filename: image.name,
            ),
          });
          await productImageController.addProductImage(formData);
        }

        Get.back(result: true);
        Get.snackbar(
          "Success",
          "Product added successfully to inventory",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add product: ${e.toString()}",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentStep == 0 ? 'Product Info' : 'Inventory Settings',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.shopName,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else if (_currentStep == 1)
            TextButton(
              onPressed: _saveProduct,
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
      body: _currentStep == 0
          ? _buildProductInfoTab()
          : _buildInventorySettingsTab(),
      bottomNavigationBar: _currentStep == 0
          ? Container(
              padding: const EdgeInsets.all(16),
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
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_images.isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Please add at least one product image",
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    setState(() => _currentStep = 1);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next: Inventory Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProductInfoTab() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Images Section
          _buildSectionHeader('Product Images', Icons.image),
          const SizedBox(height: 12),
          if (_images.isEmpty)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedImage02,
                      color: Colors.grey.shade600,
                      size: 50,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to add product images',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You can select multiple images',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(File(_images[index].path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 16,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pickSingleImage,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add More Images',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),

          // Basic Info Section
          _buildSectionHeader('Basic Information', Icons.info),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _nameController,
            label: 'Product Name',
            hint: 'Enter product name',
            required: true,
          ),
          const SizedBox(height: 12),
          Obx(() => _buildDropdownField(
                controller: _categoryController,
                label: 'Category',
                hint: 'Select category',
                items: categories.value
                    .map((cat) => DropdownMenuItem<String>(
                          value: cat['id'].toString(),
                          child: Text(cat['name'] ?? ''),
                        ))
                    .toList(),
                required: true,
                onChanged: (value) {
                  final selectedCategory = categories.value.firstWhere(
                    (item) => item["id"].toString() == _categoryController.text,
                    orElse: () => {},
                  );
                  categorySpecifications.value =
                      selectedCategory["CategoryProductSpecifications"] ?? [];
                  subcategories.value = selectedCategory["Subcategories"] ?? [];
                  _subcategoryController.text = "";

                  specificationControllers.clear();
                  for (var spec in categorySpecifications.value) {
                    final specId = spec["id"] ?? spec["label"];
                    if (spec["inputStyle"] == "multi-select") {
                      spec["value"] = <String>[];
                    } else if (spec["inputStyle"] == "toggle") {
                      spec["value"] = false;
                    } else if (spec["inputStyle"] == "range") {
                      spec["value"] = 0.0;
                    } else {
                      spec["value"] = "";
                    }
                    if (spec["inputStyle"] == "single-select") {
                      specificationControllers[specId] =
                          TextEditingController(text: "");
                    }
                  }
                  setState(() {});
                },
              )),
          const SizedBox(height: 12),
          Obx(() => subcategories.value.isNotEmpty
              ? Column(
                  children: [
                    _buildDropdownField(
                      controller: _subcategoryController,
                      label: 'Subcategory',
                      hint: 'Select subcategory',
                      items: subcategories.value
                          .map((subcat) => DropdownMenuItem<String>(
                                value: subcat['id'].toString(),
                                child: Text(subcat['name'] ?? ''),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                )
              : const SizedBox.shrink()),

          _buildDropdownField(
            controller: _measurementUnitController,
            label: 'Measurement Unit',
            hint: 'Select measurement unit',
            items: const [
              DropdownMenuItem(
                  value: 'Single/Unit', child: Text('Single/Unit')),
              DropdownMenuItem(value: 'Dozen', child: Text('Dozen (12 units)')),
              DropdownMenuItem(value: 'Set', child: Text('Set')),
              DropdownMenuItem(value: 'Pack', child: Text('Pack')),
              DropdownMenuItem(value: 'Box', child: Text('Box')),
              DropdownMenuItem(value: 'Carton', child: Text('Carton')),
              DropdownMenuItem(value: 'Bundle', child: Text('Bundle')),
              DropdownMenuItem(value: 'Pair', child: Text('Pair')),
              DropdownMenuItem(value: 'Roll', child: Text('Roll')),
              DropdownMenuItem(value: 'Bag', child: Text('Bag')),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Enter product description',
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          // Pricing Section
          _buildSectionHeader('Pricing', Icons.attach_money),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _buyingPriceController,
                  label: 'Buying Price',
                  hint: '0.00',
                  keyboardType: TextInputType.number,
                  required: true,
                  prefix: const Text('TZS '),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _sellingPriceController,
                  label: 'Selling Price',
                  hint: '0.00',
                  keyboardType: TextInputType.number,
                  required: true,
                  prefix: const Text('TZS '),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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

          // Product Identification
          _buildSectionHeader('Product Identification', Icons.qr_code),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _skuController,
            label: 'SKU (Stock Keeping Unit)',
            hint: 'Enter SKU',
          ),
          const SizedBox(height: 24),

          // Additional Options
          _buildSectionHeader('Additional Options', Icons.settings),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _linkController,
            label: 'Product Link (Optional)',
            hint: 'Paste link here',
            required: false,
          ),
          const SizedBox(height: 12),
          Obx(() => _buildSwitchTile(
                value: priceIncludeDelivery.value,
                onChanged: (value) => priceIncludeDelivery.value = value,
                title: 'Price Include Delivery',
              )),
          const SizedBox(height: 12),
          Obx(() => priceIncludeDelivery.value
              ? _buildTextField(
                  controller: _deliveryScopeController,
                  label: 'Delivery Scope',
                  hint: 'Write delivery scope here',
                  maxLines: 3,
                )
              : const SizedBox.shrink()),
          Obx(() => priceIncludeDelivery.value
              ? const SizedBox(height: 12)
              : const SizedBox.shrink()),
          Obx(() => _buildSwitchTile(
                value: isHidden.value,
                onChanged: (value) => isHidden.value = value,
                title: 'Hide this product',
                subtitle: 'When you hide product, customers won\'t see it',
              )),
          const SizedBox(height: 12),
          Obx(() => _buildSwitchTile(
                value: isNegotiable.value,
                onChanged: (value) => isNegotiable.value = value,
                title: 'Is Negotiable?',
                subtitle: 'Specify if product price is negotiable',
              )),
          const SizedBox(height: 24),

          // Category Specifications
          Obx(() {
            if (categorySpecifications.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Category Specifications', Icons.list_alt),
                const SizedBox(height: 12),
                ...categorySpecifications.value
                    .map((item) => Column(
                          children: [
                            _buildSpecificationField(item),
                            const SizedBox(height: 12),
                          ],
                        ))
                    .toList(),
              ],
            );
          }),

          // Custom Specifications
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Custom Specifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showAddCustomSpecDialog(),
                        icon: Icon(Icons.add_circle, color: primary),
                      ),
                    ],
                  ),
                  if (customSpecifications.value.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...customSpecifications.value.entries.map(
                      (entry) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                customSpecifications.value.remove(entry.key);
                                customSpecifications.refresh();
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              )),
        ],
      ),
    );
  }

  void _showAddCustomSpecDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Custom Specification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _labelController,
                label: 'Specification Label',
                hint: 'e.g., Color, RAM, Material',
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _valueController,
                label: 'Specification Value',
                hint: 'e.g., Red, 8GB, Cotton',
                required: true,
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                controller: _customUnitController,
                label: 'Unit',
                hint: 'Select unit',
                items: [
                  "No Unit",
                  "Kg",
                  "g",
                  "mg",
                  "L",
                  "mL",
                  "m",
                  "cm",
                  "mm",
                  "GB",
                  "MB",
                  "TB",
                  "W",
                  "kW",
                  "V",
                  "A",
                  "J",
                  "N",
                  "Pa",
                  "Hz",
                  "°C",
                  "°F",
                  "s",
                  "min",
                  "h"
                ]
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_labelController.text.isNotEmpty &&
                        _valueController.text.isNotEmpty) {
                      customSpecifications.value[_labelController.text] =
                          "${_valueController.text} ${_customUnitController.text != "No Unit" ? _customUnitController.text : ""}";
                      _labelController.clear();
                      _valueController.clear();
                      _customUnitController.text = "No Unit";
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add Specification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventorySettingsTab() {
    return Form(
      key: _inventoryFormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Initial Stock
          _buildSectionHeader('Initial Stock', Icons.inventory_2),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _initialStockController,
            label: 'Initial Quantity',
            hint: '0',
            keyboardType: TextInputType.number,
            required: true,
            helperText: 'Enter the initial stock quantity',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _locationController,
            label: 'Storage Location',
            hint: 'e.g., Warehouse A, Shelf 3',
          ),
          const SizedBox(height: 24),

          // Stock Alert Settings
          _buildSectionHeader('Stock Alert Settings', Icons.notifications),
          const SizedBox(height: 12),
          _buildSwitchTile(
            value: _enableLowStockAlert,
            onChanged: (value) => setState(() => _enableLowStockAlert = value),
            title: 'Enable Low Stock Alerts',
            subtitle: 'Get notified when stock is low',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _lowStockAlertController,
                  label: 'Low Stock Alert',
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
            label: 'Maximum Stock',
            hint: '100',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),

          // Location & Supplier
          _buildSectionHeader('Location & Supplier', Icons.location_on),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _locationController,
            label: 'Storage Location',
            hint: 'e.g., Shelf A1, Room 2',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _supplierController,
            label: 'Supplier',
            hint: 'Supplier name',
          ),
          const SizedBox(height: 24),

          // Inventory Tracking
          _buildSectionHeader('Inventory Tracking', Icons.track_changes),
          const SizedBox(height: 12),
          _buildSwitchTile(
            value: _trackInventory,
            onChanged: (value) => setState(() => _trackInventory = value),
            title: 'Track Inventory',
            subtitle: 'Monitor stock levels for this product',
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            value: _allowBackorder,
            onChanged: (value) => setState(() => _allowBackorder = value),
            title: 'Allow Backorder',
            subtitle: 'Allow sales when out of stock',
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            value: _stockValuationMethod,
            label: 'Stock Valuation Method',
            items: const [
              DropdownMenuItem(
                  value: 'FIFO', child: Text('FIFO (First In First Out)')),
              DropdownMenuItem(
                  value: 'LIFO', child: Text('LIFO (Last In First Out)')),
              DropdownMenuItem(value: 'AVG', child: Text('Average Cost')),
            ],
            onChanged: (value) =>
                setState(() => _stockValuationMethod = value!),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _currentStep = 0),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Product Info'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: primary),
                    foregroundColor: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Specification helper methods
  dynamic _formatSpecificationValue(Map<String, dynamic> spec) {
    final String inputStyle = spec["inputStyle"] ?? "text";
    final dynamic value = spec["value"];

    switch (inputStyle) {
      case "multi-select":
        return (value as List<String>?) ?? [];
      case "toggle":
        return value ?? false;
      case "range":
        final double doubleValue = (value ?? 0.0) as double;
        return doubleValue.round();
      case "single-select":
        return value?.toString() ?? "";
      default:
        return value?.toString() ?? "";
    }
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
      Map<String, dynamic>? values) {
    if (values == null) {
      return [
        DropdownMenuItem<String>(
          value: "",
          child: Text("No options available"),
        ),
      ];
    }

    return [
      DropdownMenuItem<String>(
        value: "",
        child: Text("Select an option"),
      ),
      ...values.entries
          .map((entry) => DropdownMenuItem<String>(
                value: entry.value.toString(),
                child: Text(entry.value.toString()),
              ))
          .toList(),
    ];
  }

  Widget _buildSpecificationField(Map<String, dynamic> spec) {
    final String inputStyle = spec["inputStyle"] ?? "text";
    final String label = spec["label"] ?? "";
    final Map<String, dynamic>? values = spec["values"];

    switch (inputStyle) {
      case "single-select":
        final specId = spec["id"] ?? spec["label"];
        if (!specificationControllers.containsKey(specId)) {
          specificationControllers[specId] = TextEditingController(text: "");
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: _buildDropdownField(
            controller: specificationControllers[specId]!,
            label: label,
            hint: "Select $label",
            items: _buildDropdownItems(values),
            onChanged: (value) {
              spec["value"] = value;
              specificationControllers[specId]!.text = value ?? "";
            },
          ),
        );
      case "multi-select":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: _buildMultiSelectField(spec),
        );
      case "toggle":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: _buildToggleSpecField(spec),
        );
      case "range":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: _buildRangeField(spec),
        );
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: _buildTextField(
            controller: TextEditingController()..text = spec["value"] ?? "",
            label: label,
            hint: "Enter ${label.toLowerCase()}",
            keyboardType: spec["expectedDataType"] == "number"
                ? TextInputType.number
                : TextInputType.text,
            onChanged: (value) {
              spec["value"] = value;
            },
          ),
        );
    }
  }

  Widget _buildMultiSelectField(Map<String, dynamic> spec) {
    final String label = spec["label"] ?? "";
    final Map<String, dynamic>? values = spec["values"];
    final List<String> selectedValues = (spec["value"] as List<String>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (values != null)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: values.entries.map((entry) {
              final String value = entry.value.toString();
              final bool isSelected = selectedValues.contains(value);

              return FilterChip(
                label: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                selected: isSelected,
                backgroundColor: Colors.grey[200],
                selectedColor: primary,
                checkmarkColor: Colors.white,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      selectedValues.add(value);
                    } else {
                      selectedValues.remove(value);
                    }
                    spec["value"] = selectedValues;
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildToggleSpecField(Map<String, dynamic> spec) {
    final String label = spec["label"] ?? "";
    final bool currentValue = spec["value"] ?? false;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Switch(
          value: currentValue,
          activeColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
          activeTrackColor: primary,
          onChanged: (bool value) {
            setState(() {
              spec["value"] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRangeField(Map<String, dynamic> spec) {
    final String label = spec["label"] ?? "";
    final double currentValue = (spec["value"] as double?) ?? 0.0;
    final double maxValue =
        spec["expectedDataType"] == "number" ? 200000.0 : 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${currentValue.round()}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: primary,
            inactiveTrackColor: primary.withOpacity(0.3),
            thumbColor: primary,
            overlayColor: primary.withOpacity(0.2),
          ),
          child: Slider(
            value: currentValue,
            min: 0,
            max: maxValue,
            divisions: 100,
            label: currentValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                spec["value"] = value.round().toDouble();
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("0",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            Text("${maxValue.round()}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
    bool enabled = true,
    Widget? prefix,
    String? helperText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            prefix: prefix,
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    TextEditingController? controller,
    String? value,
    required String label,
    String? hint,
    required List<DropdownMenuItem<String>> items,
    bool required = false,
    ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: controller != null
              ? (controller.text.isEmpty ? null : controller.text)
              : value,
          items: items,
          onChanged: (val) {
            if (controller != null) {
              controller.text = val ?? '';
            }
            if (onChanged != null) {
              onChanged(val);
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String title,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              )
            : null,
        activeColor: primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
