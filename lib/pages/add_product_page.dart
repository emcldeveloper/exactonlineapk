import 'dart:io';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/categories_controller.dart';
import 'package:e_online/controllers/product_color_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/product_image_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
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

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
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
  Rx<List<dynamic>> categorySpecifications = Rx<List<dynamic>>([]);
  Rx<Map<String, String>> customSpecifications = Rx<Map<String, String>>({});
  Rx<List<dynamic>> categories = Rx<List<dynamic>>([]);
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  TextEditingController unitController = TextEditingController(text: "No Unit");
  TextEditingController labelController = TextEditingController();
  TextEditingController valueController = TextEditingController();

  void _openColorPicker() {
    Color pickedColor = Colors.blue;
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Select"),
              onPressed: () {
                setState(() {
                  selectedColors.add(pickedColor);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
    CategoriesController()
        .getCategories(keyword: "", page: 1, limit: 100)
        .then((res) {
      categories.value = res;
      if (res.isNotEmpty) {
        categoryController.text = res[0]["id"].toString();
        categorySpecifications.value =
            res[0]["CategoryProductSpecifications"] ?? [];
      }
    });
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
                            ParagraphText("Select product images"),
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
                    onChanged: () {
                      final selectedCategory = categories.value.firstWhere(
                        (item) =>
                            item["id"].toString() == categoryController.text,
                        orElse: () => {},
                      );
                      categorySpecifications.value =
                          selectedCategory["CategoryProductSpecifications"] ??
                              [];
                    },
                    label: "Product Category",
                    items: categories.value
                        .map((item) => DropdownMenuItem(
                              value: item["id"].toString(),
                              child: Text(item["name"]),
                            ))
                        .toList(),
                  ),
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
                        activeTrackColor:
                            const Color.fromARGB(255, 169, 145, 145),
                        focusColor: Colors.black,
                        inactiveThumbColor: Colors.black,
                        onChanged: (bool value) {
                          isHidden.value = value;
                        },
                      ),
                    ),
                  ],
                ),
                spacer1(),

                // Category-based specifications
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
                        (item) => TextForm(
                          label: item["label"],
                          onChanged: (value) {
                            item["value"] = value;
                          },
                          hint: "Enter product ${item["label"]}",
                        ),
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
                  child:
                      loading ? const CustomLoader(color: Colors.white) : null,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      if (_images.isEmpty) {
                        showErrorSnackbar(
                          title: "No Product Images",
                          description: "Please add at least one image",
                        );
                        return;
                      }

                      // Combine category and custom specifications
                      Map<String, String> combinedSpecifications = {
                        ...{
                          for (var item in categorySpecifications.value)
                            item["label"]: item["value"] ?? ""
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
                        "specifications": combinedSpecifications,
                        "deliveryScope": deliveryScopeController.text,
                        "CategoryId": categoryController.text,
                        "ShopId": userController.user.value["Shops"][0]["id"],
                      };
                      setState(() => loading = true);
                      print(payload);
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
                        Get.back();
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
