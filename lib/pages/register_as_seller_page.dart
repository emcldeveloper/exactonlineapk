import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/my_shop_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterAsSellerPage extends StatefulWidget {
  const RegisterAsSellerPage({super.key});

  @override
  State<RegisterAsSellerPage> createState() => _RegisterAsSellerPageState();
}

class _RegisterAsSellerPageState extends State<RegisterAsSellerPage> {
  List<PlatformFile> _files = [];
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
    return Column(
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
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
          decoration: InputDecoration(
            fillColor: primaryColor,
            filled: true,
            hintText: "Enter phone number",
            hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                  Icons.add,
                  color: mutedTextColor,
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
                        Icon(Icons.cloud_upload, size: 50, color: Colors.black),
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
                        leading: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
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
          decoration: InputDecoration(
            fillColor: primaryColor,
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
            hintText: "Write short business description",
            hintStyle: TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        spacer(),
        ParagraphText("Agent Name", fontWeight: FontWeight.bold),
        spacer(),
        TextFormField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            fillColor: primaryColor,
            filled: true,
            hintText: "Enter agent name",
            hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),
        spacer(),
        ParagraphText("Agent License Number", fontWeight: FontWeight.bold),
        spacer(),
        TextFormField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            fillColor: primaryColor,
            filled: true,
            hintText: "Enter license number",
            hintStyle: TextStyle(color: Colors.black, fontSize: 12),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            enabledBorder: OutlineInputBorder(
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
          decoration: InputDecoration(
            fillColor: primaryColor,
            filled: true,
            hintText: "Enter agent address",
            hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                child: Icon(
                  Icons.add,
                  color: mutedTextColor,
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
                        Icon(Icons.cloud_upload, size: 50, color: Colors.black),
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
                        leading: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
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
          decoration: InputDecoration(
            fillColor: primaryColor,
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
            hintText: "Write short agent description",
            hintStyle: TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
      ],
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
            Icons.arrow_back_ios_new_outlined,
            color: mutedTextColor,
            size: 14.0,
          ),
        ),
        title: HeadingText("Register your business"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: primaryColor, height: 1.0),
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
              customButton(
                onTap: () {
                  Get.to(() => MyShopPage());
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
