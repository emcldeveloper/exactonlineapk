import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/shop_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/my_shop_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:dio/dio.dart' as dio;

class RegisterAsSellerPage extends StatefulWidget {
  const RegisterAsSellerPage({super.key});
  @override
  State<RegisterAsSellerPage> createState() => _RegisterAsSellerPageState();
}

class _RegisterAsSellerPageState extends State<RegisterAsSellerPage> {
  final List<PlatformFile> _files = [];
  var isLoading = false.obs;

  final UserController userController = Get.find();
  final ShopController shopController = Get.put(ShopController());

  final TextEditingController businessnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController businessaddressController =
      TextEditingController();
  final TextEditingController businessdescriptionController =
      TextEditingController();
  final TextEditingController agentnameController = TextEditingController();
  final TextEditingController agentaddressController = TextEditingController();
  final TextEditingController agentphoneController = TextEditingController();
  final TextEditingController agentdescriptionController =
      TextEditingController();

  final GlobalKey<FormState> _businessFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _agentFormKey = GlobalKey<FormState>();

  String userId = "";
  @override
  void initState() {
    userId = userController.user.value["id"] ?? "";
    super.initState();
  }

  String? selectedBusiness = "Business"; // Default selection

  final List<Map<String, String>> businessType = [
    {"name": "Business"},
    {"name": "Agent"},
  ];

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

  Widget _buildBusinessForm() {
    return Form(
      key: _businessFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
          spacer(),
          ParagraphText("Business Phone number", fontWeight: FontWeight.bold),
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
              hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
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
              hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
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
                    child: Icon(
                      OctIcons.plus,
                      size: 18,
                    )),
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
                          Icon(
                            AntDesign.cloud_upload_outline,
                            size: 40,
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
                          contentPadding: EdgeInsets.all(0),
                          leading: HugeIcon(
                            icon: HugeIcons.strokeRoundedPdf01,
                            color: Colors.red,
                            size: 22.0,
                          ),
                          title: Text(entry.value.name),
                          trailing: GestureDetector(
                            onTap: () => _removeFile(entry.key),
                            child: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 16.0,
                            ),
                          ),
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
              labelStyle: const TextStyle(color: Colors.black, fontSize: 12),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: primaryColor,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              hintText: "Write short business description",
              hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentForm() {
    return Form(
      key: _agentFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          spacer(),
          ParagraphText("Agent Name", fontWeight: FontWeight.bold),
          spacer(),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: agentnameController,
            validator: (value) {
              value = value?.trim();
              if (value == null || value.trim().isEmpty) {
                return "Agent Name cannot be empty";
              }
              if (value.length < 3) {
                return "Agent Name must be at least 3 characters long";
              }
              return null;
            },
            decoration: InputDecoration(
              fillColor: primaryColor,
              filled: true,
              hintText: "Enter agent name",
              hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
          spacer(),
          ParagraphText("Agent Phone Number", fontWeight: FontWeight.bold),
          spacer(),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: agentphoneController,
            validator: (value) {
              value = value?.trim();
              if (value == null || value.trim().isEmpty) {
                return "phone number cannot be empty";
              }
              if (value.length < 10) {
                return "Enter a valid phone number";
              }
              return null;
            },
            decoration: InputDecoration(
              fillColor: primaryColor,
              filled: true,
              hintText: "Enter phone number",
              hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
          spacer(),
          ParagraphText("Agent Address", fontWeight: FontWeight.bold),
          spacer(),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: agentaddressController,
            validator: (value) {
              value = value?.trim();
              if (value == null || value.trim().isEmpty) {
                return "Agent Address cannot be empty";
              }
              if (value.length < 5) {
                return "Agent Address must be at least 5 characters long";
              }
              return null;
            },
            decoration: InputDecoration(
              fillColor: primaryColor,
              filled: true,
              hintText: "Enter agent address",
              hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
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
                "Upload Agent National ID Number",
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
                    color: Colors.grey,
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
                            icon: AntDesign.cloud_upload_outline,
                            color: Colors.black,
                            size: 40.0,
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
                            child: const Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 16.0,
                            ),
                          ),
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
            controller: agentdescriptionController,
            validator: (value) {
              value = value?.trim();
              if (value == null || value.trim().isEmpty) {
                return "Agent Description cannot be empty";
              }
              if (value.length < 30) {
                return "Agent Description must be at least 30 characters long";
              }
              return null;
            },
            decoration: InputDecoration(
              fillColor: primaryColor,
              filled: true,
              labelStyle: const TextStyle(color: Colors.black, fontSize: 12),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: primaryColor,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              hintText: "Write short agent description",
              hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ],
      ),
    );
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
        title: HeadingText("Register your business"),
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
            children: [
              Row(
                children: businessType.map((type) {
                  return Row(
                    children: [
                      Radio<String>(
                        value: type['name']!,
                        groupValue: selectedBusiness,
                        onChanged: (value) {
                          setState(() {
                            selectedBusiness = value!;
                          });
                        },
                        activeColor: secondaryColor,
                      ),
                      ParagraphText(type['name']!),
                    ],
                  );
                }).toList(),
              ),
              selectedBusiness == "Business"
                  ? _buildBusinessForm()
                  : _buildAgentForm(),
              spacer3(),
              Obx(() {
                return customButton(
                  onTap: () async {
                    if (selectedBusiness == "Business") {
                      if (_businessFormKey.currentState?.validate() == true) {
                        isLoading.value = true;
                        if (_files.isEmpty) {
                          print("Please select at least one file.");
                          isLoading.value = false;
                          return;
                        }

                        // Create the payload for the initial request
                        final payload = {
                          "UserId": userId.isNotEmpty ? userId : "unknown",
                          "registeredBy": "business",
                          "name": businessnameController.text.trim(),
                          "phone": phoneController.text.trim(),
                          "address": businessaddressController.text.trim(),
                          "description":
                              businessdescriptionController.text.trim(),
                        };
                        try {
                          // Send the initial data to create the shop
                          var response =
                              await shopController.createShop(payload);
                          var shopId = response['body']["id"];
                          //add shop to shops in user payload
                          userController.user.value["Shops"] = [
                            response['body']
                          ];

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
                          Get.offAll(() => const MyShopPage(),
                              arguments: {'origin': 'RegisterAsSellerPage'});
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
                    } else {
                      if (_agentFormKey.currentState?.validate() == true) {
                        isLoading.value = true;
                        if (_files.isEmpty) {
                          print("Please select at least one file.");
                          isLoading.value = false;
                          return;
                        }

                        // Create the payload for the initial request
                        final payload = {
                          "UserId": userId.isNotEmpty ? userId : "unknown",
                          "registeredBy": "agent",
                          "name": agentnameController.text.trim(),
                          "address": agentaddressController.text.trim(),
                          "phone": agentphoneController.text.trim(),
                          "description": agentdescriptionController.text.trim(),
                        };

                        try {
                          // Send the initial data to create the shop
                          var response =
                              await shopController.createShop(payload);
                          var shopId = response['body']["id"];
                          // Send files one by one
                          for (var file in _files) {
                            var fileData = dio.FormData.fromMap({
                              "file": await MultipartFile(file.path!,
                                  filename: file.name),
                              "title": file.name, // Sending filename as title
                              "ShopId": shopId,
                            });
                            await shopController.createShopDocuments(fileData);
                          }

                          isLoading.value = false;
                          Get.snackbar(
                              "Success", "Agent Shop created successfully!",
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedTick01,
                                  color: Colors.white));
                          Get.offAll(() => const MyShopPage(),
                              arguments: {'origin': 'RegisterAsSellerPage'});
                        } catch (e) {
                          isLoading.value = false;
                          print(e.toString());
                          Get.snackbar("Error", "Error creating shop account",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                              icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedCancel02,
                                  color: Colors.white));
                        }
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
    );
  }
}
