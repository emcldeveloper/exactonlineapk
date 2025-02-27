import 'dart:io';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/categories_controller.dart';
import 'package:e_online/controllers/product_color_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/product_image_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/utils/snackbars.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:e_online/widgets/editimage.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/select_form.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dio/dio.dart' as dio;

class EditProductPage extends StatefulWidget {
  var product;
  EditProductPage({this.product, super.key});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  Rx<bool> priceIncludeDelivery = true.obs;
  Rx<bool> isHidden = false.obs;
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  List<Color> selectedColors = [];
  UserController userController = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController(text: "All");
  TextEditingController priceController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  TextEditingController deliveryScopeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Rx<List> categories = Rx<List>([]);
  TextEditingController unitController = TextEditingController(text: "No Unit");
  TextEditingController labelController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  var specifications = {};
  final _formKey = GlobalKey<FormState>();
  void _openColorPicker() {
    Color pickedColor = Colors.blue; // Default color for the picker

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pick a Color"),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (Color color) {
                pickedColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Select"),
              onPressed: () {
                setState(() {
                  selectedColors
                      .add(pickedColor); // Add the picked color to the list
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool loading = false;
  @override
  void initState() {
    CategoriesController()
        .getCategories(keyword: "", page: 1, limit: 100)
        .then((res) {
      categories.value = res;
      categoryController.text = res[0]["id"];
    });
    nameController.text = widget.product["name"];
    priceController.text = widget.product["sellingPrice"];
    descriptionController.text = widget.product["description"];
    linkController.text = widget.product["productLink"];
    deliveryScopeController.text = widget.product["deliveryScope"];
    priceIncludeDelivery.value = widget.product["priceIncludesDelivery"];
    specifications = widget.product["specifications"];
    // TODO: implement initState
    super.initState();
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
                    Obx(
                      () => selectForm(
                          textEditingController: categoryController,
                          label: "Product Category",
                          items: categories.value
                              .map((item) => DropdownMenuItem(
                                    value: item["id"].toString(),
                                    child: Text(item["name"]),
                                  ))
                              .toList()),
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
                                  "Product Specifications",
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
                                            HeadingText("Add specifications"),
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
                                                if (labelController
                                                        .text.isNotEmpty &&
                                                    valueController
                                                        .text.isNotEmpty) {
                                                  specifications[labelController
                                                          .text] =
                                                      "${valueController.text} ${unitController.text != "No Unit" ? unitController.text : ""}";
                                                  labelController.clear();
                                                  valueController.clear();
                                                  unitController.text =
                                                      "No Unit";
                                                  Get.back();
                                                  setState(() {}); // Update UI
                                                }
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

                          /// ✅ **Loop Through Specifications**
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: specifications.entries.map((entry) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ParagraphText(
                                        entry.key, // Specification Label
                                      ),
                                    ),
                                    ParagraphText(
                                      entry.value, // Specification Value + Unit
                                      fontWeight: FontWeight.bold,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        specifications
                                            .remove(entry.key); // Remove item
                                        setState(() {}); // Update UI
                                      },
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextForm(
                        label: "Product Description",
                        textEditingController: descriptionController,
                        lines: 5,
                        hint: "Write short product description"),
                    spacer3(),
                    customButton(
                      child: loading
                          ? const CustomLoader(
                              color: Colors.white,
                            )
                          : null,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          // Map<String, String> jsonSpecifications = {
                          //   for (var item in specifications.value)
                          //     item["label"]: item["value"]
                          // };

                          var payload = {
                            "name": nameController.text,
                            "sellingPrice": priceController.text,
                            "productLink": linkController.text,
                            "description": descriptionController.text,
                            "priceIncludeDelivery": priceIncludeDelivery.value,
                            "specifications": specifications,
                            "deliveryScope": deliveryScopeController.text,
                          };
                          setState(() {
                            loading = true;
                          });

                          ProductController()
                              .editProduct(widget.product["id"], payload)
                              .then((res) async {
                            //upload colors

                            Get.back();
                            showSuccessSnackbar(
                                title: "Changed successfully",
                                description: "Product is edited successfully");
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
