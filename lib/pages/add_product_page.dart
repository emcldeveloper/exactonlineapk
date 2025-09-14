import 'dart:io';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/categories_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/product_image_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/utils/snackbars.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/editimage.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/select_form.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/text_form.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  Rx<bool> priceIncludeDelivery = true.obs;
  Rx<bool> isHidden = false.obs;
  Rx<bool> isNegotiable = true.obs;
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  List<Color> selectedColors = [];
  UserController userController = Get.find();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController =
      TextEditingController(); // Initialize empty until categories load
  TextEditingController subcategoryController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  TextEditingController deliveryScopeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Rx<List<dynamic>> categorySpecifications = Rx<List<dynamic>>([]);
  Rx<Map<String, String>> customSpecifications = Rx<Map<String, String>>({});
  Rx<List<dynamic>> categories = Rx<List<dynamic>>([]);
  Rx<List<dynamic>> subcategories = Rx<List<dynamic>>([]);
  // Map to store specification controllers
  Map<String, TextEditingController> specificationControllers = {};
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  TextEditingController unitController = TextEditingController(text: "No Unit");
  TextEditingController labelController = TextEditingController();
  TextEditingController valueController = TextEditingController();

  Future<void> _pickImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() {
          _images.addAll(selectedImages);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking images')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking image')),
      );
    }
  }

  void _openImageEditBottomSheet(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImageEditBottomSheet(
        onReplace: () async {
          final XFile? newImage =
              await _picker.pickImage(source: ImageSource.gallery);
          if (newImage != null) {
            setState(() {
              _images[index] = newImage;
            });
          }
        },
        onDelete: () {
          setState(() {
            _images.removeAt(index);
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    trackScreenView("AddProductPage");
    CategoriesController()
        .getCategories(keyword: "", page: 1, limit: 100)
        .then((res) {
      categories.value = res;
      if (res.isNotEmpty) {
        categoryController.text = res[0]["id"].toString();
        categorySpecifications.value =
            res[0]["CategoryProductSpecifications"] ?? [];
        subcategories.value = res[0]["Subcategories"] ?? [];
        subcategoryController.text = "";
        print(
            "Initial load: Found ${categorySpecifications.value.length} specifications for ${res[0]["name"]}"); // Debug log

        // Clear old specification controllers
        specificationControllers.clear();

        // Initialize specification values based on inputStyle
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

          // Initialize controller for single-select fields
          if (spec["inputStyle"] == "single-select") {
            specificationControllers[specId] = TextEditingController(text: "");
          }
        }
      }
    });
  }

  // Build specification field based on inputStyle
  Widget _buildSpecificationField(Map<String, dynamic> spec) {
    final String inputStyle = spec["inputStyle"] ?? "text";
    final String label = spec["label"] ?? "";
    final Map<String, dynamic>? values = spec["values"];

    switch (inputStyle) {
      case "single-select":
        // Create or get existing controller for this specification
        final specId = spec["id"] ?? spec["label"];
        if (!specificationControllers.containsKey(specId)) {
          specificationControllers[specId] = TextEditingController(text: "");
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: selectForm(
            label: label,
            textEditingController: specificationControllers[specId]!,
            onChanged: (value) {
              spec["value"] = value;
              specificationControllers[specId]!.text = value ?? "";
              print(
                  "Specification ${spec["label"]} set to: $value"); // Debug log
            },
            items: _buildDropdownItems(values),
          ),
        );

      case "multi-select":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _buildMultiSelectField(spec),
        );

      case "toggle":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _buildToggleField(spec),
        );

      case "range":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _buildRangeField(spec),
        );

      default: // text, number, or any other type
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TextForm(
            label: label,
            textInputType: spec["expectedDataType"] == "number"
                ? TextInputType.number
                : TextInputType.text,
            onChanged: (value) {
              spec["value"] = value;
            },
            hint: "Enter ${label.toLowerCase()}",
          ),
        );
    }
  }

  // Build dropdown items from values object
  List<DropdownMenuItem<String>> _buildDropdownItems(
      Map<String, dynamic>? values) {
    if (values == null)
      return [
        DropdownMenuItem<String>(
          value: "",
          child: ParagraphText("No options available"),
        ),
      ];

    return [
      DropdownMenuItem<String>(
        value: "",
        child: ParagraphText("Select an option"),
      ),
      ...values.entries
          .map((entry) => DropdownMenuItem<String>(
                value: entry.value.toString(),
                child: ParagraphText(entry.value.toString()),
              ))
          .toList(),
    ];
  }

  // Build multi-select field with chips
  Widget _buildMultiSelectField(Map<String, dynamic> spec) {
    final String label = spec["label"] ?? "";
    final Map<String, dynamic>? values = spec["values"];
    final List<String> selectedValues = (spec["value"] as List<String>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParagraphText(
          label,
          fontWeight: FontWeight.bold,
          fontSize: 14,
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
                label: ParagraphText(
                  value,
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                selected: isSelected,
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.orange,
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
        if (selectedValues.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 4.0,
              children: selectedValues
                  .map((value) => Chip(
                        label: ParagraphText(value, fontSize: 11),
                        backgroundColor: Colors.orange,
                        labelStyle: const TextStyle(color: Colors.white),
                        deleteIconColor: Colors.white,
                        onDeleted: () {
                          setState(() {
                            selectedValues.remove(value);
                            spec["value"] = selectedValues;
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  // Build toggle field with switch
  Widget _buildToggleField(Map<String, dynamic> spec) {
    final String label = spec["label"] ?? "";
    final bool currentValue = spec["value"] ?? false;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ParagraphText(
                label,
                fontWeight: FontWeight.bold,
              ),
              ParagraphText(
                "Enable or disable ${label.toLowerCase()}",
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Switch(
          value: currentValue,
          activeColor: Colors.white,
          inactiveTrackColor: Colors.white,
          activeTrackColor: Colors.orange,
          focusColor: Colors.black,
          inactiveThumbColor: Colors.black,
          onChanged: (bool value) {
            setState(() {
              spec["value"] = value;
            });
          },
        ),
      ],
    );
  }

  // Build range field with slider
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
            ParagraphText(
              label,
              fontWeight: FontWeight.bold,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ParagraphText(
                "${currentValue.round()}",
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orange,
            inactiveTrackColor: Colors.orange.withOpacity(0.3),
            thumbColor: Colors.orange,
            overlayColor: Colors.orange.withOpacity(0.2),
          ),
          child: Slider(
            value: currentValue,
            min: 0,
            max: maxValue,
            divisions: 100,
            label: currentValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                spec["value"] =
                    value.round().toDouble(); // Store as rounded double
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ParagraphText("0", fontSize: 12, color: Colors.grey[600]),
            ParagraphText("${maxValue.round()}",
                fontSize: 12, color: Colors.grey[600]),
          ],
        ),
      ],
    );
  }

  // Format specification value based on inputStyle for API submission
  dynamic _formatSpecificationValue(Map<String, dynamic> spec) {
    final String inputStyle = spec["inputStyle"] ?? "text";
    final dynamic value = spec["value"];

    switch (inputStyle) {
      case "multi-select":
        // Return array of selected values
        return (value as List<String>?) ?? [];

      case "toggle":
        // Return boolean value
        return value ?? false;

      case "range":
        // Return rounded integer value
        final double doubleValue = (value ?? 0.0) as double;
        return doubleValue.round();

      case "single-select":
        // Return selected string value
        return value?.toString() ?? "";

      default: // text, number, or any other type
        return value?.toString() ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Container(
            color: Colors.transparent,
            child: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.black,
              size: 16.0,
            ),
          ),
        ),
        title: HeadingText("Add Product"),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                spacer(),
                ParagraphText("Product Images"),
                spacer(),
                if (_images.isEmpty)
                  Center(
                    child: GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: AntDesign.file_image_outline,
                              color: Colors.black,
                              size: 50.0,
                            ),
                            spacer(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ParagraphText(
                                  "Select product images (Images must be related to the product you are uploading)",
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
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
                            return GestureDetector(
                              onTap: () => _openImageEditBottomSheet(index),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(File(_images[index].path)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickSingleImage,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedAdd01,
                              color: Colors.white,
                              size: 22.0,
                            ),
                            label: ParagraphText(
                              "Add More",
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                spacer1(),
                TextForm(
                  label: "Product Name",
                  textEditingController: nameController,
                  hint: "Enter product name",
                ),
                Obx(
                  () => selectForm(
                    textEditingController: categoryController,
                    onChanged: (value) {
                      print("Category changed to: $value"); // Debug log
                      final selectedCategory = categories.value.firstWhere(
                        (item) =>
                            item["id"].toString() == categoryController.text,
                        orElse: () => {},
                      );
                      print(
                          "Selected category: ${selectedCategory["name"]}"); // Debug log
                      categorySpecifications.value =
                          selectedCategory["CategoryProductSpecifications"] ??
                              [];
                      print(
                          "Found ${categorySpecifications.value.length} specifications"); // Debug log

                      // Update subcategories for the selected category
                      subcategories.value =
                          selectedCategory["Subcategories"] ?? [];
                      subcategoryController.text = "";

                      // Clear old specification controllers
                      specificationControllers.clear();

                      // Initialize specification values based on inputStyle
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

                        // Initialize controller for single-select fields
                        if (spec["inputStyle"] == "single-select") {
                          specificationControllers[specId] =
                              TextEditingController(text: "");
                        }
                      }
                    },
                    label: "Product Category",
                    items: [
                      // Add a placeholder item
                      DropdownMenuItem(
                        value: "",
                        child: Text("Select a category"),
                      ),
                      ...categories.value
                          .map((item) => DropdownMenuItem(
                                value: item["id"].toString(),
                                child: Text(item["name"]),
                              ))
                          .toList(),
                    ],
                  ),
                ),
                Obx(
                  () => subcategories.value.isNotEmpty
                      ? selectForm(
                          label: "Subcategory",
                          textEditingController: subcategoryController,
                          items: [
                            DropdownMenuItem(
                              value: "",
                              child: Text("Select a subcategory"),
                            ),
                            ...subcategories.value
                                .map((item) => DropdownMenuItem(
                                      value: item["id"].toString(),
                                      child: Text(item["name"] ?? ""),
                                    ))
                                .toList(),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                TextForm(
                  label: "Product price",
                  textEditingController: priceController,
                  textInputType: TextInputType.number,
                  hint: "Enter product price",
                ),
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: priceIncludeDelivery.value,
                        onChanged: (bool? newValue) {
                          priceIncludeDelivery.value = newValue ?? false;
                        },
                        activeColor: secondaryColor,
                      ),
                    ),
                    ParagraphText("Price include delivery"),
                  ],
                ),
                Obx(
                  () => priceIncludeDelivery.value
                      ? TextForm(
                          label: "Delivery scope",
                          lines: 5,
                          textEditingController: deliveryScopeController,
                          hint: "Write delivery scope here",
                        )
                      : Container(),
                ),
                TextForm(
                  label: "Product Link (optional)",
                  withValidation: false,
                  textEditingController: linkController,
                  hint: "Paste link here",
                ),
                spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ParagraphText(
                            "Hide this product",
                            fontWeight: FontWeight.bold,
                          ),
                          ParagraphText(
                            "When you hide product, customers won't see it",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Obx(
                      () => Switch(
                        value: isHidden.value,
                        activeColor: Colors.white,
                        inactiveTrackColor: Colors.white,
                        activeTrackColor: primary,
                        focusColor: Colors.black,
                        inactiveThumbColor: Colors.black,
                        onChanged: (bool value) {
                          isHidden.value = value;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ParagraphText(
                            "Is Negotiable ?",
                            fontWeight: FontWeight.bold,
                          ),
                          ParagraphText(
                            "Specify if product price is negotiable",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Obx(
                      () => Switch(
                        value: isNegotiable.value,
                        activeColor: Colors.white,
                        inactiveTrackColor: Colors.white,
                        activeTrackColor: primary,
                        focusColor: Colors.black,
                        inactiveThumbColor: Colors.black,
                        onChanged: (bool value) {
                          isNegotiable.value = value;
                        },
                      ),
                    ),
                  ],
                ),

                spacer1(),

                // Category-based specifications with different input styles
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (categorySpecifications.value.isNotEmpty)
                        ParagraphText(
                          "Category Specifications",
                          fontWeight: FontWeight.bold,
                        ),
                      ...categorySpecifications.value.map(
                        (item) => _buildSpecificationField(item),
                      ),
                    ],
                  ),
                ),
                spacer1(),
                // Custom user-added specifications
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ParagraphText(
                              "Custom Specifications",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Get.bottomSheet(
                                SingleChildScrollView(
                                  child: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 30),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        spacer(),
                                        HeadingText("Add Custom Specification"),
                                        TextForm(
                                          label: "Specification Label",
                                          textEditingController:
                                              labelController,
                                          hint:
                                              "Enter specification label eg: color, RAM",
                                        ),
                                        TextForm(
                                          label: "Specification Value",
                                          textEditingController:
                                              valueController,
                                          hint:
                                              "Enter specification value eg: red, 8GB",
                                        ),
                                        selectForm(
                                          label: "Specification Unit",
                                          textEditingController: unitController,
                                          items: [
                                            "No Unit",
                                            "Kg", "g", "mg", // Mass
                                            "L", "mL", // Volume
                                            "m", "cm", "mm", // Length
                                            "GB", "MB", "TB", // Digital Storage
                                            "W", "kW", // Power
                                            "V", "A", // Voltage & Current
                                            "J", "N",
                                            "Pa", // Energy, Force, Pressure
                                            "Hz", // Frequency
                                            "°C", "°F", // Temperature
                                            "s", "min", "h" // Time
                                          ]
                                              .map((item) => DropdownMenuItem(
                                                    value: item,
                                                    child: ParagraphText(item),
                                                  ))
                                              .toList(),
                                        ),
                                        spacer(),
                                        customButton(
                                          onTap: () {
                                            if (labelController
                                                    .text.isNotEmpty &&
                                                valueController
                                                    .text.isNotEmpty) {
                                              customSpecifications.value[
                                                      labelController.text] =
                                                  "${valueController.text} ${unitController.text != "No Unit" ? unitController.text : ""}";
                                              labelController.clear();
                                              valueController.clear();
                                              unitController.text = "No Unit";
                                              Get.back();
                                              setState(() {});
                                            }
                                          },
                                          text: "Add Specification",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedAdd01,
                              color: Colors.grey,
                              size: 22.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      ...customSpecifications.value.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: ParagraphText(entry.key)),
                              ParagraphText(
                                entry.value,
                                fontWeight: FontWeight.bold,
                              ),
                              IconButton(
                                onPressed: () {
                                  customSpecifications.value.remove(entry.key);
                                  customSpecifications.refresh();
                                },
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                spacer1(),
                TextForm(
                  label: "Product Description",
                  textEditingController: descriptionController,
                  lines: 5,
                  hint: "Write short product description",
                ),
                spacer3(),
                customButton(
                  loading: loading,
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_images.isEmpty) {
                        showErrorSnackbar(
                          title: "No Product Images",
                          description: "Please add at least one image",
                        );
                        return;
                      }

                      final shopId =
                          await SharedPreferencesUtil.getCurrentShopId(
                              userController.user.value["Shops"] ?? []);

                      if (shopId == null) {
                        showErrorSnackbar(
                          title: "No Shop Selected",
                          description: "Please select a shop first",
                        );
                        return;
                      }

                      // Combine category and custom specifications
                      Map<String, dynamic> combinedSpecifications = {
                        ...{
                          for (var item in categorySpecifications.value)
                            item["label"]: _formatSpecificationValue(item)
                        },
                        ...customSpecifications.value,
                      };
                      var payload = {
                        "name": nameController.text,
                        "sellingPrice": priceController.text,
                        "productLink": linkController.text,
                        "description": descriptionController.text,
                        "priceIncludeDelivery": priceIncludeDelivery.value,
                        "isHidden": isHidden.value,
                        "isNegotiable": isNegotiable.value,
                        "specifications": combinedSpecifications,
                        "deliveryScope": deliveryScopeController.text,
                        "CategoryId": categoryController.text,
                        "SubcategoryId": subcategoryController.text,
                        "ShopId": shopId,
                      };
                      print("🆚");
                      print(payload);
                      setState(() => loading = true);
                      print(payload);
                      await analytics.logEvent(
                        name: 'seller_add_product',
                        parameters: {
                          'item_name': nameController.text,
                          "description": descriptionController.text,
                          'category': categoryController.text,
                          'price': priceController.text,
                          "ShopId": shopId,
                        },
                      );

                      ProductController().addProduct(payload).then((res) async {
                        // Upload images
                        var imagePayload = _images.map((item) async {
                          var formData = dio.FormData.fromMap({
                            "ProductId": res["id"],
                            "file": await dio.MultipartFile.fromFile(
                              item.path,
                              filename: item.path.split("/").last,
                            ),
                          });
                          return ProductImageController()
                              .addProductImage(formData);
                        });
                        await Future.wait(imagePayload);
                        setState(() => loading = false);
                        Get.back(
                            result: true); // Return true to indicate success
                        showSuccessSnackbar(
                          title: "Added successfully",
                          description: "Product is added successfully",
                        );
                      });
                    }
                  },
                  text: loading ? "" : "Add Product",
                ),
                SizedBox(
                  height: 0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
