import 'dart:io';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/categories_controller.dart';
import 'package:e_online/controllers/service_controller.dart';
import 'package:e_online/controllers/service_image_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/utils/snackbars.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:e_online/widgets/editimage.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/select_form.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/text_form.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  Rx<bool> priceIncludeDelivery = true.obs;
  Rx<bool> isHidden = false.obs;
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  List<Color> selectedColors = [];
  UserController userController = Get.find();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
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
    trackScreenView("AddServicePage");
    CategoriesController()
        .getCategories(keyword: "", page: 1, type: "service", limit: 100)
        .then((res) {
      categories.value = res;
      if (res.isNotEmpty) {
        categoryController.text = res[0]["id"].toString();
        categorySpecifications.value =
            res[0]["CategoryServiceSpecifications"] ?? [];
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
        title: HeadingText("Add Service"),
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
                ParagraphText("Service Images"),
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
                            const HugeIcon(
                              icon: AntDesign.file_image_outline,
                              color: Colors.black,
                              size: 50.0,
                            ),
                            spacer(),
                            ParagraphText("Select service images"),
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
                            icon: const HugeIcon(
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
                  label: "Service Name",
                  textEditingController: nameController,
                  hint: "Enter service name",
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
                          selectedCategory["CategoryServiceSpecifications"] ??
                              [];
                    },
                    label: "Service Category",
                    items: categories.value
                        .map((item) => DropdownMenuItem(
                              value: item["id"].toString(),
                              child: Text(item["name"]),
                            ))
                        .toList(),
                  ),
                ),
                TextForm(
                  label: "Service price",
                  textEditingController: priceController,
                  textInputType: TextInputType.number,
                  hint: "Enter service price",
                ),
                TextForm(
                  label: "Service Link (optional)",
                  withValidation: false,
                  textEditingController: linkController,
                  hint: "Paste link here",
                ),
                spacer1(),
                TextForm(
                  label: "Service Description",
                  textEditingController: descriptionController,
                  lines: 5,
                  hint: "Write short service description",
                ),
                spacer3(),
                customButton(
                  loading: loading,
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_images.isEmpty) {
                        showErrorSnackbar(
                          title: "No Service Images",
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

                      var payload = {
                        "name": nameController.text,
                        "price": priceController.text,
                        "serviceLink": linkController.text,
                        "description": descriptionController.text,
                        "CategoryId": categoryController.text,
                        "ShopId": shopId,
                      };
                      setState(() => loading = true);
                      await analytics.logEvent(
                        name: 'seller_add_service',
                        parameters: {
                          'item_name': nameController.text,
                          "description": descriptionController.text,
                          'category': categoryController.text,
                          'price': priceController.text,
                          "ShopId": shopId,
                        },
                      );

                      ServiceController().addService(payload).then((res) async {
                        // Upload images
                        var imagePayload = _images.map((item) async {
                          var formData = dio.FormData.fromMap({
                            "ServiceId": res["id"],
                            "file": await dio.MultipartFile.fromFile(
                              item.path,
                              filename: item.path.split("/").last,
                            ),
                          });
                          return ServiceImageController()
                              .addServiceImage(formData);
                        });
                        await Future.wait(imagePayload);
                        setState(() => loading = false);
                        Get.back(
                            result: true); // Return true to indicate success
                        showSuccessSnackbar(
                          title: "Added successfully",
                          description: "Service is added successfully",
                        );
                      });
                    }
                  },
                  text: loading ? "" : "Add Service",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
