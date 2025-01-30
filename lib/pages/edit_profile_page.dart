import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/way_page.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/popup_alert.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  var isLoading = false.obs;

  Rx<File?> selectedImage = Rx<File?>(null);

  final UserController userController = Get.find();

  final TextEditingController businessnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();

  // Function to pick an image
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    businessnameController.text = userController.user.value["name"] ?? "";
    phoneController.text = userController.user.value["phone"] ?? "";
    emailController.text = userController.user.value["email"] ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String id = userController.user.value["id"];
    String avatar = userController.user.value["image"];

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Container(
              color: Colors.transparent,
              child: Icon(
                Icons.arrow_back_ios,
                color: mutedTextColor,
                size: 16.0,
              ),
            )),
        title: HeadingText("Edit Profile"),
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
              Obx(() {
                return InkWell(
                  onTap: pickImage,
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: Stack(
                      children: [
                        ClipOval(
                          child: selectedImage.value != null
                              ? Image.file(
                                  selectedImage.value!,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                )
                              : avatar.isNotEmpty 
                                  ? CachedNetworkImage(
                                      imageUrl: avatar,
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : HugeIcon(
                                      icon: HugeIcons.strokeRoundedUserCircle,
                                      color: Colors.black,
                                      size: 80,
                                    ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: const Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedPencilEdit02,
                                  color: Colors.white,
                                  size: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              spacer1(),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParagraphText(
                      "Username",
                      fontWeight: FontWeight.bold,
                    ),
                    spacer(),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: businessnameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name cannot be empty";
                        }
                        if (value.length < 3) {
                          return "Name must be at least 3 characters long";
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
                        hintText: "Enter business name",
                        hintStyle:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                    spacer(),
                    ParagraphText(
                      "Phone number",
                      fontWeight: FontWeight.bold,
                    ),
                    spacer(),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: phoneController,
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
                        enabled: false,
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                        ),
                        hintText: "Enter phone number",
                        hintStyle:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                    spacer(),
                    ParagraphText(
                      "Email address (optional)",
                      fontWeight: FontWeight.bold,
                    ),
                    spacer(),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: emailController,
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
                        hintText: "Enter business address",
                        hintStyle:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              spacer3(),
              Obx(() {
                return customButton(
                  onTap: () async {
                    if (_formKey.currentState?.validate() == true) {
                      isLoading.value = true;

                      var formData = dio.FormData.fromMap({
                        "name": businessnameController.text,
                        "phone": phoneController.text,
                        "email": emailController.text,
                        "file": selectedImage.value != null
                            ? await dio.MultipartFile.fromFile(
                                selectedImage.value!.path,
                                filename:
                                    selectedImage.value!.path.split(" ").last)
                            : null,
                      });

                      try {
                        var user =
                            await userController.updateUserData(id, formData);
                        userController.user.value = user["body"];
                        isLoading.value = false;
                        Get.snackbar("Success", "Profile updated successfully!",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedTick01,
                                color: Colors.white));
                      } catch (e) {
                        isLoading.value = false;
                        Get.snackbar("Error", e.toString(),
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedCancel01,
                                color: Colors.white));
                      }
                    }
                  },
                  text: isLoading.value ? null : "Save Changes",
                  width: double.infinity,
                  child: isLoading.value
                      ? const CustomLoader(
                          color: Colors.white,
                        )
                      : null,
                );
              }),
              spacer1(),
              InkWell(
                onTap: () {
                  showPopupAlert(
                    context,
                    iconAsset: "assets/images/closeicon.jpg",
                    heading: "Log Out",
                    text: "Are you sure you want to LogOut?",
                    button1Text: "No",
                    button1Action: () {
                      Navigator.of(context).pop();
                    },
                    button2Text: "Yes",
                    button2Action: () async {
                      Navigator.of(context).pop();
                      await SharedPreferencesUtil.removeAccessToken();
                      Get.offAll(() => WayPage());
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                        icon: HugeIcons.strokeRoundedLogout02,
                        color: Colors.red),
                    SizedBox(
                      width: 8,
                    ),
                    ParagraphText("Log Out", color: Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
