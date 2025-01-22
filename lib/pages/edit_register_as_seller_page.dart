import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/my_shop_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class EditRegisterAsSellerPage extends StatefulWidget {
  final String shopId; // Accept shop ID as a parameter

  const EditRegisterAsSellerPage(this.shopId, {super.key});

  @override
  State<EditRegisterAsSellerPage> createState() =>
      _EditRegisterAsSellerPageState();
}

class _EditRegisterAsSellerPageState extends State<EditRegisterAsSellerPage> {
  final List<PlatformFile> _files = [];
  String? selectedBusiness = "Business"; // Default selection

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              spacer(),
              ParagraphText("Business Name", fontWeight: FontWeight.bold),
              spacer(),
              TextFormField(
                keyboardType: TextInputType.text,
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
              ParagraphText("Business Phone number",
                  fontWeight: FontWeight.bold),
              spacer(),
              TextFormField(
                keyboardType: TextInputType.text,
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
              spacer3(),
              customButton(
                onTap: () {
                  Get.to(() => const MyShopPage());
                },
                text: "Submit Details",
              ),
              spacer1(),
            ],
          ),
        ),
      ),
    );
  }
}
