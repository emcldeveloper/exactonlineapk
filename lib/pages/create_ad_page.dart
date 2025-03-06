import 'dart:io';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/main_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/editimage.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

class CreateAdPage extends StatefulWidget {
  const CreateAdPage({super.key});

  @override
  State<CreateAdPage> createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  @override
  void initState() {
    super.initState();
    trackScreenView("CreateAdPage");
  }

  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, DateTime? current) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
        if (controller == _startDateController) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
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
              Icons.arrow_back_ios,
              color: secondaryColor,
              size: 16.0,
            ),
          ),
        ),
        title: HeadingText("Create an Ad"),
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
              spacer(),
              ParagraphText(
                "Upload Image",
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
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedAdd01,
                            color: Colors.black,
                            size: 22.0,
                          ),
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
                "Start Date",
                fontWeight: FontWeight.bold,
              ),
              spacer(),
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                onTap: () =>
                    _selectDate(context, _startDateController, _startDate),
                decoration: InputDecoration(
                  fillColor: primaryColor,
                  filled: true,
                  hintText: "Select a date",
                  hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
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
                  suffixIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    color: Colors.grey,
                    size: 16.0,
                  ),
                ),
              ),
              spacer(),
              ParagraphText(
                "End Date",
                fontWeight: FontWeight.bold,
              ),
              spacer(),
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                onTap: () => _selectDate(context, _endDateController, _endDate),
                decoration: InputDecoration(
                  fillColor: primaryColor,
                  filled: true,
                  hintText: "Select a date",
                  hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
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
                  suffixIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    color: Colors.grey,
                    size: 16.0,
                  ),
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
                  Get.to(() => const MainPage());
                },
                text: "Create an Ad",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
