import 'dart:io';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/categories_controller.dart';
import 'package:e_online/controllers/service_controller.dart';
import 'package:e_online/controllers/service_image_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/utils/page_analytics.dart';
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

class EditServicePage extends StatefulWidget {
  var service;
  EditServicePage({this.service, super.key});

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
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
    trackScreenView("EditServicePage");
    CategoriesController()
        .getCategories(keyword: "", page: 1, type: "service", limit: 100)
        .then((res) {
      categories.value = res;
      categoryController.text = res[0]["id"];
    });
    nameController.text = widget.service["name"];
    priceController.text = widget.service["price"];
    descriptionController.text = widget.service["description"];
    linkController.text = widget.service["serviceLink"];
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
        title: HeadingText("Edit Service"),
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
                        label: "Service Name",
                        textEditingController: nameController,
                        hint: "Enter service name"),
                    Obx(
                      () => selectForm(
                          textEditingController: categoryController,
                          label: "Service Category",
                          items: categories.value
                              .map((item) => DropdownMenuItem(
                                    value: item["id"].toString(),
                                    child: Text(item["name"]),
                                  ))
                              .toList()),
                    ),
                    TextForm(
                        label: "Service price",
                        textEditingController: priceController,
                        textInputType: TextInputType.number,
                        hint: "Enter service price"),
                    // selectForm(),

                    TextForm(
                        label: "Service Link (optional)",
                        withValidation: false,
                        textEditingController: linkController,
                        hint: "Past link here"),

                    spacer1(),

                    const SizedBox(
                      height: 10,
                    ),
                    TextForm(
                        label: "Service Description",
                        textEditingController: descriptionController,
                        lines: 5,
                        hint: "Write short service description"),
                    spacer3(),
                    customButton(
                      loading: loading,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          // Map<String, String> jsonSpecifications = {
                          //   for (var item in specifications.value)
                          //     item["label"]: item["value"]
                          // };

                          var payload = {
                            "name": nameController.text,
                            "price": priceController.text,
                            "serviceLink": linkController.text,
                            "description": descriptionController.text,
                          };
                          setState(() {
                            loading = true;
                          });

                          ServiceController()
                              .editService(widget.service["id"], payload)
                              .then((res) async {
                            //upload colors

                            Get.back();
                            showSuccessSnackbar(
                                title: "Changed successfully",
                                description: "Service is edited successfully");
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
