import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/categories_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/utils/snackbars.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/select_form.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class EditProductPage extends StatefulWidget {
  final dynamic product;
  const EditProductPage({this.product, super.key});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  Rx<bool> priceIncludeDelivery = false.obs;
  Rx<bool> isHidden = false.obs;
  Rx<bool> isNegotiable = true.obs;
  UserController userController = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
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

  TextEditingController unitController = TextEditingController(text: "No Unit");
  TextEditingController labelController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  var specifications = {};
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

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
          specificationControllers[specId] =
              TextEditingController(text: spec["value"]?.toString() ?? "");
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ParagraphText(label),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: _buildDropdownItems(values).any((item) =>
                        item.value == specificationControllers[specId]!.text)
                    ? specificationControllers[specId]!.text
                    : null, // Use null if value doesn't exist
                onChanged: (value) {
                  if (value != null) {
                    print(
                        "Before update - ${spec["label"]}: ${spec["value"]}"); // Debug

                    // Update the spec value
                    spec["value"] = value;
                    specificationControllers[specId]!.text = value;

                    // Also update the original specification in the list to ensure reactivity
                    final specIndex = categorySpecifications.value.indexWhere(
                        (item) => (item["id"] ?? item["label"]) == specId);
                    if (specIndex != -1) {
                      categorySpecifications.value[specIndex]["value"] = value;
                      categorySpecifications.refresh(); // Force reactive update
                    }

                    print(
                        "After update - ${spec["label"]}: ${spec["value"]}"); // Debug
                    print(
                        "Specification ${spec["label"]} set to: $value"); // Debug log
                  }
                },
                decoration: InputDecoration(
                  fillColor: primaryColor,
                  filled: true,
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  hintText: "Select ${label.toLowerCase()}",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                items: _buildDropdownItems(values),
              ),
            ],
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
        // Create or get existing controller for this specification
        final specId = spec["id"] ?? spec["label"];
        if (!specificationControllers.containsKey(specId)) {
          specificationControllers[specId] =
              TextEditingController(text: spec["value"]?.toString() ?? "");
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TextForm(
            label: label,
            textEditingController: specificationControllers[specId]!,
            textInputType: spec["expectedDataType"] == "number"
                ? TextInputType.number
                : TextInputType.text,
            onChanged: (value) {
              spec["value"] = value;
              specificationControllers[specId]!.text = value;

              // Also update the original specification in the list to ensure reactivity
              final specIndex = categorySpecifications.value.indexWhere(
                  (item) => (item["id"] ?? item["label"]) == specId);
              if (specIndex != -1) {
                categorySpecifications.value[specIndex]["value"] = value;
                categorySpecifications.refresh(); // Force reactive update
              }

              print("Text field ${spec["label"]} set to: $value"); // Debug log
            },
            hint: "Enter ${label.toLowerCase()}",
          ),
        );
    }
  }

  // Build dropdown items from values object
  List<DropdownMenuItem<String>> _buildDropdownItems(
      Map<String, dynamic>? values) {
    if (values == null) return [];

    return [
      // Add a placeholder item
      DropdownMenuItem(
        value: "",
        child: ParagraphText("Select an option", color: Colors.grey),
      ),
      ...values.entries
          .map((entry) => DropdownMenuItem(
                value: entry.value.toString(),
                child: ParagraphText(entry.value.toString()),
              ))
          .toList(),
    ];
  }

  // Build multi-select field widget
  Widget _buildMultiSelectField(Map<String, dynamic> spec) {
    final String label = spec["label"] ?? "";
    final Map<String, dynamic>? values = spec["values"];
    final List<String> selectedValues = (spec["value"] as List<String>?) ?? [];

    if (values == null) {
      return ParagraphText("No options available for $label");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParagraphText(label, fontWeight: FontWeight.bold),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: values.entries.map((entry) {
            final String value = entry.value.toString();
            final bool isSelected = selectedValues.contains(value);

            return FilterChip(
              label: ParagraphText(value, fontSize: 12),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedValues.add(value);
                  } else {
                    selectedValues.remove(value);
                  }
                  spec["value"] = selectedValues;

                  // Also update the original specification in the list to ensure reactivity
                  final specId = spec["id"] ?? spec["label"];
                  final specIndex = categorySpecifications.value.indexWhere(
                      (item) => (item["id"] ?? item["label"]) == specId);
                  if (specIndex != -1) {
                    categorySpecifications.value[specIndex]["value"] =
                        List<String>.from(selectedValues);
                    categorySpecifications.refresh(); // Force reactive update
                  }

                  print(
                      "Multi-select ${spec["label"]} updated: $selectedValues"); // Debug log
                });
              },
              selectedColor: Colors.orange.withOpacity(0.3),
              checkmarkColor: Colors.orange,
            );
          }).toList(),
        ),
      ],
    );
  }

  // Build toggle field widget
  Widget _buildToggleField(Map<String, dynamic> spec) {
    final String label = spec["label"] ?? "";
    final bool currentValue = (spec["value"] as bool?) ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ParagraphText(label, fontWeight: FontWeight.bold),
        ),
        Switch(
          value: currentValue,
          onChanged: (bool value) {
            setState(() {
              spec["value"] = value;

              // Also update the original specification in the list to ensure reactivity
              final specId = spec["id"] ?? spec["label"];
              final specIndex = categorySpecifications.value.indexWhere(
                  (item) => (item["id"] ?? item["label"]) == specId);
              if (specIndex != -1) {
                categorySpecifications.value[specIndex]["value"] = value;
                categorySpecifications.refresh(); // Force reactive update
              }

              print("Toggle ${spec["label"]} set to: $value"); // Debug log
            });
          },
          activeColor: Colors.orange,
        ),
      ],
    );
  }

  // Build range field widget
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
            ParagraphText(label, fontWeight: FontWeight.bold),
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
                final roundedValue = value.round().toDouble();
                spec["value"] = roundedValue; // Store as rounded double

                // Also update the original specification in the list to ensure reactivity
                final specId = spec["id"] ?? spec["label"];
                final specIndex = categorySpecifications.value.indexWhere(
                    (item) => (item["id"] ?? item["label"]) == specId);
                if (specIndex != -1) {
                  categorySpecifications.value[specIndex]["value"] =
                      roundedValue;
                  categorySpecifications.refresh(); // Force reactive update
                }

                print(
                    "Range ${spec["label"]} set to: $roundedValue"); // Debug log
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
  void initState() {
    trackScreenView("EditProductPage");
    print(widget.product);
    // Initialize basic prodcuct data
    nameController.text = widget.product["name"]?.toString() ?? "";
    priceController.text = widget.product["sellingPrice"]?.toString() ?? "";
    descriptionController.text =
        widget.product["description"]?.toString() ?? "";
    linkController.text = widget.product["productLink"]?.toString() ?? "";
    deliveryScopeController.text =
        widget.product["deliveryScope"]?.toString() ?? "";
    priceIncludeDelivery.value =
        widget.product["priceIncludesDelivery"] ?? false;
    isHidden.value = widget.product["isHidden"] ?? false;
    isNegotiable.value = widget.product["isNegotiable"] ?? false;
    specifications = widget.product["specifications"] ?? {};

    // Load categories and initialize specifications
    CategoriesController()
        .getCategories(keyword: "", page: 1, limit: 100)
        .then((res) {
      categories.value = res;
      if (res.isNotEmpty) {
        // Set the product's current category
        final String productCategoryId =
            widget.product["CategoryId"]?.toString() ?? "";
        categoryController.text = productCategoryId.isNotEmpty
            ? productCategoryId
            : res[0]["id"].toString();

        print(
            "Setting category controller to: ${categoryController.text}"); // Debug log
        print(
            "Available categories: ${res.map((c) => c["id"]).toList()}"); // Debug log

        // Find the selected category and load its specifications
        final selectedCategory = categories.value.firstWhere(
          (item) => item["id"].toString() == categoryController.text,
          orElse: () => {},
        );

        categorySpecifications.value =
            selectedCategory["CategoryProductSpecifications"] ?? [];

        // Initialize subcategories for the selected category
        subcategories.value = selectedCategory["Subcategories"] ?? [];
        final String productSubcategoryId =
            widget.product["SubcategoryId"]?.toString() ?? "";
        if (productSubcategoryId.isNotEmpty) {
          final exists = subcategories.value
              .any((s) => s["id"].toString() == productSubcategoryId);
          subcategoryController.text = exists ? productSubcategoryId : "";
        } else {
          subcategoryController.text = "";
        }

        // Clear old specification controllers
        specificationControllers.clear();

        // Initialize specification values from existing product data
        for (var spec in categorySpecifications.value) {
          final specId = spec["id"] ?? spec["label"];
          final String specLabel = spec["label"] ?? "";
          final String inputStyle = spec["inputStyle"] ?? "text";

          // Get existing value from product specifications
          final existingValue = specifications[specLabel];

          if (inputStyle == "multi-select") {
            // Handle multi-select values
            if (existingValue is String && existingValue.isNotEmpty) {
              spec["value"] = [existingValue];
            } else if (existingValue is List) {
              spec["value"] = List<String>.from(existingValue);
            } else {
              spec["value"] = <String>[];
            }
          } else if (inputStyle == "toggle") {
            // Handle boolean values
            spec["value"] = existingValue ?? false;
          } else if (inputStyle == "range") {
            // Handle numeric values (convert to double)
            if (existingValue is num) {
              spec["value"] = existingValue.toDouble();
            } else {
              spec["value"] = 0.0;
            }
          } else {
            // Handle text/single-select values
            if (inputStyle == "single-select") {
              // For single-select, ensure we have a string value
              spec["value"] = existingValue?.toString() ?? "";
              specificationControllers[specId] =
                  TextEditingController(text: spec["value"]);
            } else {
              // For text fields, also create controller
              spec["value"] = existingValue?.toString() ?? "";
              specificationControllers[specId] =
                  TextEditingController(text: spec["value"]);
            }
          }

          print(
              "Initialized spec ${spec["label"]} with value: ${spec["value"]}"); // Debug log
        }

        setState(() {}); // Update UI after initialization
      }
    });

    super.initState();
  }

  // Format specification value for display
  String _formatSpecificationDisplayValue(dynamic value) {
    if (value is bool) {
      return value ? "Yes" : "No";
    } else if (value is num) {
      return value.toString();
    } else if (value is List) {
      return value.join(", ");
    } else {
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
            child: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: secondaryColor,
              size: 16.0,
            ),
          ),
        ),
        title: HeadingText("Edit Product"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    spacer1(),
                    TextForm(
                        label: "Product Name",
                        textEditingController: nameController,
                        hint: "Enter product name"),
                    // Category dropdown with better error handling
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ParagraphText("Product Category"),
                          const SizedBox(height: 5),
                          DropdownButtonFormField<String>(
                            value: categories.value.any((item) =>
                                    item["id"].toString() ==
                                    categoryController.text)
                                ? categoryController.text
                                : null, // Use null if value doesn't exist
                            onChanged: (value) {
                              if (value != null) {
                                categoryController.text = value;
                                // Find the selected category and load its specifications
                                final selectedCategory =
                                    categories.value.firstWhere(
                                  (item) => item["id"].toString() == value,
                                  orElse: () => {},
                                );
                                categorySpecifications.value = selectedCategory[
                                        "CategoryProductSpecifications"] ??
                                    [];

                                // Update subcategories on category change
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
                                print(
                                    "Category changed to: $value"); // Debug log
                                print(
                                    "Loaded ${categorySpecifications.value.length} specifications"); // Debug log
                              }
                            },
                            decoration: InputDecoration(
                              fillColor: primaryColor,
                              filled: true,
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              hintText: "Select a category",
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                            items: [
                              // Add a placeholder item
                              DropdownMenuItem(
                                value: null,
                                child: ParagraphText("Select a category",
                                    color: Colors.grey),
                              ),
                              ...categories.value
                                  .map((item) => DropdownMenuItem(
                                        value: item["id"].toString(),
                                        child: Text(item["name"]),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Subcategory selector (only when category has subcategories)
                    Obx(
                      () => subcategories.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: selectForm(
                                label: "Subcategory",
                                textEditingController: subcategoryController,
                                items: [
                                  DropdownMenuItem(
                                    value: "",
                                    child: ParagraphText("Select a subcategory",
                                        color: Colors.grey),
                                  ),
                                  ...subcategories.value
                                      .map((item) => DropdownMenuItem(
                                            value: item["id"].toString(),
                                            child: Text(item["name"] ?? ""),
                                          ))
                                      .toList(),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    TextForm(
                        label: "Product price",
                        textEditingController: priceController,
                        textInputType: TextInputType.number,
                        hint: "Enter product price"),
                    // selectForm(),

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
                        ParagraphText(
                          "Price include delivery",
                        ),
                      ],
                    ),
                    Obx(
                      () => Column(
                        children: [
                          priceIncludeDelivery.value
                              ? TextForm(
                                  label: "Delivery scope",
                                  lines: 5,
                                  textEditingController:
                                      deliveryScopeController,
                                  hint: "Write delivery scope here")
                              : Container(),
                        ],
                      ),
                    ),
                    TextForm(
                        label: "Product Link (optional)",
                        withValidation: false,
                        textEditingController: linkController,
                        hint: "Past link here"),

                    spacer1(),

                    // Category Specifications Section
                    Obx(
                      () => categorySpecifications.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ParagraphText(
                                    "Category Specifications",
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ...categorySpecifications.value.map(
                                    (item) => _buildSpecificationField(item),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ),

                    spacer1(),

                    // Custom Specifications Section (existing system)
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Column(
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
                                  Get.bottomSheet(SingleChildScrollView(
                                    child: Container(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 30),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),
                                            HeadingText(
                                                "Add custom specification"),
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
                                              textEditingController:
                                                  unitController,
                                              items: [
                                                "No Unit",
                                                "Kg", "g", "mg", // Mass
                                                "L", "mL", // Volume
                                                "m", "cm", "mm", // Length
                                                "GB", "MB",
                                                "TB", // Digital Storage
                                                "W", "kW", // Power
                                                "V", "A", // Voltage & Current
                                                "J", "N",
                                                "Pa", // Energy, Force, Pressure
                                                "Hz", // Frequency
                                                "°C", "°F", // Temperature
                                                "s", "min", "h" // Time
                                              ]
                                                  .map((item) =>
                                                      DropdownMenuItem(
                                                        value: item,
                                                        child:
                                                            ParagraphText(item),
                                                      ))
                                                  .toList(),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            customButton(
                                              onTap: () {
                                                final label =
                                                    labelController.text.trim();
                                                final val =
                                                    valueController.text.trim();

                                                if (label.isEmpty ||
                                                    val.isEmpty) {
                                                  Get.snackbar(
                                                    "Missing info",
                                                    "Please provide both label and value.",
                                                  );
                                                  return;
                                                }

                                                // Prevent adding a custom spec that duplicates a category specification label
                                                final Set<String>
                                                    categoryLabels =
                                                    categorySpecifications.value
                                                        .map((s) =>
                                                            (s["label"] ?? "")
                                                                .toString())
                                                        .toSet();
                                                if (categoryLabels
                                                    .contains(label)) {
                                                  Get.snackbar(
                                                    "Not Allowed",
                                                    "'${label}' is already defined in category specifications.",
                                                  );
                                                  return;
                                                }

                                                specifications[label] =
                                                    "${val} ${unitController.text != "No Unit" ? unitController.text : ""}";
                                                labelController.clear();
                                                valueController.clear();
                                                unitController.text = "No Unit";
                                                Get.back();
                                                setState(() {}); // Update UI
                                              },
                                              text: "Add Specification",
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ));
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

                          /// ✅ **Loop Through Custom Specifications**
                          Builder(builder: (context) {
                            final Set<String> categoryLabels =
                                categorySpecifications.value
                                    .map((s) => (s["label"] ?? "").toString())
                                    .toSet();
                            final customOnly = specifications.entries
                                .where((e) => !categoryLabels.contains(e.key))
                                .toList();

                            if (customOnly.isEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ParagraphText(
                                  "No custom specifications yet",
                                  color: Colors.grey,
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: customOnly.map((entry) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: ParagraphText(
                                          entry.key,
                                        ),
                                      ),
                                      ParagraphText(
                                        _formatSpecificationDisplayValue(
                                            entry.value),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          specifications.remove(entry.key);
                                          setState(() {});
                                        },
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          })
                        ],
                      ),
                    ),
                    SizedBox(height: 10),

                    // Hidden toggle
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

                    // Negotiable toggle
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
                    TextForm(
                        label: "Product Description",
                        textEditingController: descriptionController,
                        lines: 5,
                        hint: "Write short product description"),
                    spacer3(),
                    customButton(
                      loading: loading,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          // Combine category and custom specifications
                          // Ensure category specs take precedence over custom specs
                          final Map<String, dynamic> categorySpecMap = {
                            for (var item in categorySpecifications.value)
                              item["label"]: _formatSpecificationValue(item)
                          };

                          // Remove any custom specs that duplicate category spec labels
                          final Set<String> categoryLabels =
                              categorySpecMap.keys.toSet();
                          final Map<String, dynamic> sanitizedCustomSpecs =
                              Map<String, dynamic>.from(specifications)
                                ..removeWhere((key, value) =>
                                    categoryLabels.contains(key));

                          // Merge with custom first, then category to override duplicates
                          Map<String, dynamic> combinedSpecifications = {
                            ...sanitizedCustomSpecs,
                            ...categorySpecMap,
                          };

                          print(
                              "Category specs before submission:"); // Debug log
                          for (var item in categorySpecifications.value) {
                            print(
                                "  ${item["label"]}: ${item["value"]} (${item["inputStyle"]})");
                            print(
                                "  Formatted: ${_formatSpecificationValue(item)}");
                          }
                          print(
                              "Combined specifications: $combinedSpecifications"); // Debug log

                          var payload = {
                            "name": nameController.text,
                            "sellingPrice": priceController.text,
                            "productLink": linkController.text,
                            "description": descriptionController.text,
                            "priceIncludesDelivery": priceIncludeDelivery.value,
                            "isHidden": isHidden.value,
                            "isNegotiable": isNegotiable.value,
                            "CategoryId": categoryController.text,
                            "SubcategoryId": subcategoryController.text,
                            "specifications": combinedSpecifications,
                            "deliveryScope": deliveryScopeController.text,
                          };

                          print("Edit payload: $payload"); // Debug log

                          setState(() {
                            loading = true;
                          });

                          ProductController()
                              .editProduct(widget.product["id"], payload)
                              .then((res) async {
                            setState(() {
                              loading = false;
                            });
                            Get.back();
                            showSuccessSnackbar(
                                title: "Changed successfully",
                                description: "Product is edited successfully");
                          }).catchError((error) {
                            setState(() {
                              loading = false;
                            });
                            print("Edit error: $error");
                          });
                        }
                      },
                      text: loading ? "" : "Save Changes",
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
