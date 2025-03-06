import 'dart:io';

import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/shop_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/setting_myshop_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:e_online/widgets/editimage.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

class EditRegisterAsSellerPage extends StatefulWidget {
  final String shopId;

  const EditRegisterAsSellerPage(this.shopId, {super.key});

  @override
  State<EditRegisterAsSellerPage> createState() =>
      _EditRegisterAsSellerPageState();
}

class _EditRegisterAsSellerPageState extends State<EditRegisterAsSellerPage> {
  final UserController userController = Get.find();
  final ShopController shopController = Get.find();
  final TextEditingController businessnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController businessaddressController =
      TextEditingController();
  final TextEditingController businessdescriptionController =
      TextEditingController();

  Rx<bool> priceIncludeDelivery = true.obs;
  Rx<bool> isHidden = false.obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<PlatformFile> _files = [];
  var isLoading = false.obs;
  String userId = "";
  Map<String, dynamic> selectedBusiness = {};

  @override
  void initState() {
    super.initState();
    trackScreenView("EditRegisterAsSellerPage");
    userId = userController.user.value["id"] ?? "";
    List businesses = userController.user.value['Shops'];

    selectedBusiness = businesses.firstWhere(
      (business) => business["id"] == widget.shopId,
      orElse: () => {},
    );

    // Set default values for form fields if not edited
    businessnameController.text = selectedBusiness['name'] ?? '';
    phoneController.text = selectedBusiness['phone'] ?? '';
    businessaddressController.text = selectedBusiness['address'] ?? '';
    businessdescriptionController.text = selectedBusiness['description'] ?? '';
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage.value = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking image')),
      );
    }
  }

  void _openImageEditBottomSheet() {
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
              selectedImage.value = File(newImage.path);
            });
          }
        },
        onDelete: () {
          setState(() {
            selectedImage.value = null;
          });
        },
      ),
    );
  }

  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Only allow PDFs
    );

    if (result != null) {
      setState(() {
        _files.addAll(result.files.where((file) => !_files.contains(file)));
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: mutedTextColor,
            size: 16.0,
          ),
        ),
        title: HeadingText("Edit Business Information"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: primaryColor, height: 1.0),
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
                ParagraphText("Business Images", fontWeight: FontWeight.bold),
                spacer(),
                if (selectedImage.value == null)
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("Select shop image"),
                        ],
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _openImageEditBottomSheet,
                    child: Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(selectedImage.value!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImage.value = null;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                spacer(),
                ParagraphText("Business Name", fontWeight: FontWeight.bold),
                spacer(),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: businessnameController,
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.trim().isEmpty) {
                      return "Business Name cannot be empty";
                    }
                    if (value.length < 3) {
                      return "Business Name must be at least 3 characters long";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    fillColor: primaryColor,
                    filled: true,
                    hintText: "Enter business name",
                    hintStyle:
                        const TextStyle(color: Colors.black, fontSize: 12),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                spacer(),
                ParagraphText("Business Phone number",
                    fontWeight: FontWeight.bold),
                spacer(),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: phoneController,
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.trim().isEmpty) {
                      return "Phone number cannot be empty";
                    }
                    if (value.length < 10) {
                      return "Enter a valid 10-digit phone number";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    fillColor: primaryColor,
                    filled: true,
                    hintText: "Enter phone number",
                    hintStyle:
                        const TextStyle(color: Colors.black, fontSize: 12),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                spacer(),
                ParagraphText("Business Address", fontWeight: FontWeight.bold),
                spacer(),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: businessaddressController,
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.trim().isEmpty) {
                      return "Business Address cannot be empty";
                    }
                    if (value.length < 5) {
                      return "Business Address must be at least 5 characters long";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    fillColor: primaryColor,
                    filled: true,
                    hintText: "Enter business address",
                    hintStyle:
                        const TextStyle(color: Colors.black, fontSize: 12),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ParagraphText(
                      "Upload business licence & TIN Number",
                      fontWeight: FontWeight.bold,
                    ),
                    // Display the Icon only if there are files
                    if (_files.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _pickFiles();
                        },
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedAdd01,
                          color: Colors.black,
                          size: 16.0,
                        ),
                      ),
                  ],
                ),
                spacer(),
                _files.isEmpty
                    ? Center(
                        child: GestureDetector(
                          onTap: _pickFiles,
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
                                  icon: HugeIcons.strokeRoundedUpload01,
                                  color: Colors.black,
                                  size: 50.0,
                                ),
                                spacer(),
                                ParagraphText("Upload files here*"),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: _files
                            .asMap()
                            .entries
                            .map(
                              (entry) => ListTile(
                                leading: HugeIcon(
                                  icon: HugeIcons.strokeRoundedPdf01,
                                  color: Colors.red,
                                  size: 22.0,
                                ),
                                title: Text(entry.value.name),
                                trailing: GestureDetector(
                                    onTap: () => _removeFile(entry.key),
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedCancel01,
                                      color: Colors.black,
                                      size: 16.0,
                                    )),
                              ),
                            )
                            .toList(),
                      ),
                spacer(),
                ParagraphText(
                  "Short Description",
                  fontWeight: FontWeight.bold,
                ),
                spacer(),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  controller: businessdescriptionController,
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.trim().isEmpty) {
                      return "Business Description cannot be empty";
                    }
                    if (value.length < 30) {
                      return "Business Description must be at least 30 characters long";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    fillColor: primaryColor,
                    filled: true,
                    labelStyle:
                        const TextStyle(color: Colors.black, fontSize: 12),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: primaryColor,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    hintText: "Write short business description",
                    hintStyle:
                        const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ),
                spacer3(),
                Obx(() {
                  return customButton(
                    onTap: () async {
                      if (_formKey.currentState?.validate() == true) {
                        isLoading.value = true;
                        // Create the payload for the initial request
                        var formData = dio.FormData.fromMap({
                          "UserId": userId.isNotEmpty ? userId : "unknown",
                          "registeredBy": "business",
                          "name": businessnameController.text.trim(),
                          "phone": phoneController.text.trim(),
                          "address": businessaddressController.text.trim(),
                          "description":
                              businessdescriptionController.text.trim(),
                          "file": selectedImage.value != null
                              ? await dio.MultipartFile.fromFile(
                                  selectedImage.value!.path,
                                  filename:
                                      selectedImage.value!.path.split(" ").last)
                              : null,
                        });

                        try {
                          // Send the initial data to create the shop
                          var response = await shopController.updateShopData(
                              widget.shopId, formData);
                          var shopId = response['body']["id"];

                          // Send files one by one
                          for (var file in _files) {
                            var fileData = dio.FormData.fromMap({
                              "file": await dio.MultipartFile.fromFile(
                                file.path!,
                                filename: file.name,
                              ),
                              "title": file.name,
                              "ShopId": shopId,
                            });
                            await shopController.createShopDocuments(fileData);
                          }

                          isLoading.value = false;
                          Get.snackbar(
                              "Success", "Business Shop created successfully!",
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedTick01,
                                  color: Colors.white));
                          Get.to(() => SettingMyshopPage(
                                from: "formPage",
                              ));
                        } catch (e) {
                          isLoading.value = false;
                          Get.snackbar("Error", "Error creating shop account",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                              icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedCancel02,
                                  color: Colors.white));
                        }
                      }
                    },
                    text: isLoading.value ? null : "Submit Details",
                    child: isLoading.value
                        ? const CustomLoader(
                            color: Colors.white,
                          )
                        : null,
                  );
                }),
                spacer1(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
