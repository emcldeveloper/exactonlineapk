import 'dart:io';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/editimage.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  bool _isChecked = true;
  bool _isSwitched = false;
  List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            color: Colors.transparent,
            child:
                Icon(Icons.arrow_back_ios_new_outlined, color: secondaryColor),
          ),
        ),
        title: HeadingText("Add Product"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              spacer(),
              ParagraphText(
                "Product Images",
                fontWeight: FontWeight.bold,
              ),
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
                          Icon(Icons.cloud_upload,
                              size: 50, color: Colors.black),
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
                            child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image:
                                          FileImage(File(_images[index].path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
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
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text("Add More"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              spacer1(),
              ParagraphText(
                "Product Name",
                fontWeight: FontWeight.bold,
              ),
              spacer(),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  fillColor: bgColor,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  hintText: "Enter product name",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
              spacer(),
              ParagraphText(
                "Product Price",
                fontWeight: FontWeight.bold,
              ),
              spacer(),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  fillColor: bgColor,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  hintText: "Enter product price",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
              spacer(),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isChecked = newValue ?? false;
                      });
                    },
                    activeColor: secondaryColor,
                  ),
                  ParagraphText(
                    "Price include delivery",
                  ),
                ],
              ),
              spacer(),
              ParagraphText(
                "Product link (optional)",
                fontWeight: FontWeight.bold,
              ),
              spacer(),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  fillColor: bgColor,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  hintText: "Paste the link here...",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                ),
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
                          "When you hide product, customers won't see it ",
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isSwitched,
                    activeColor: Colors.black,
                    onChanged: (bool value) {
                      setState(() {
                        _isSwitched = value;
                      });
                    },
                  ),
                ],
              ),
              spacer(),
              ParagraphText(
                "Product description",
                fontWeight: FontWeight.bold,
              ),
              spacer(),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  fillColor: bgColor,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  hintText: "Write short product description",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
              spacer3(),
              customButton(
                onTap: () {
                  if (_images.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please add at least one image')),
                    );
                    return;
                  }
                  Get.to(() => const HomePage());
                },
                text: "Add Product",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
