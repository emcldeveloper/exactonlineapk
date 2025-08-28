import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/reel_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:e_online/utils/snackbars.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/custom_loader.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;

class AddReelPage extends StatefulWidget {
  const AddReelPage({super.key});

  @override
  State<AddReelPage> createState() => _AddReelPageState();
}

class _AddReelPageState extends State<AddReelPage> {
  final Rx<bool> priceIncludeDelivery = true.obs;
  final Rx<bool> isHidden = false.obs;
  final List<XFile> _videos = [];
  final ImagePicker _picker = ImagePicker();
  final UserController userController = Get.find();
  final TextEditingController captionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    trackScreenView("AddReelPage");
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? pickedFile =
          await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _videos.add(pickedFile);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking video')),
      );
    }
  }

  Future<void> _uploadReel() async {
    if (_formKey.currentState!.validate()) {
      if (_videos.isEmpty) {
        showErrorSnackbar(
          title: "No Reel Video",
          description: "Please add a video",
        );
        return;
      }

      try {
        setState(() {
          loading = true;
        });

        final shopId = await SharedPreferencesUtil.getCurrentShopId(
            userController.user.value["Shops"] ?? []);

        final dio.FormData videoPayload = dio.FormData.fromMap({
          "file": await dio.MultipartFile.fromFile(
            _videos.first.path,
            filename: _videos.first.path.split("/").last,
          ),
          "caption": captionController.text,
          "ShopId": shopId,
        });

        // Upload reel with the video file
        await ReelController().addReel(videoPayload);

        setState(() {
          loading = false;
        });

        Get.back(result: true); // Return true to indicate success
        showSuccessSnackbar(
          title: "Added successfully",
          description: "Reel added successfully",
        );
      } catch (e) {
        setState(() {
          loading = false;
        });
        showErrorSnackbar(
          title: "Error",
          description: "Failed to upload reel. Please try again.",
        );
      }
    }
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
        title: HeadingText("Add Reel"),
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
                    spacer(),
                    ParagraphText("Reel Video"),
                    spacer(),
                    if (_videos.isEmpty)
                      Center(
                        child: GestureDetector(
                          onTap: _pickVideo,
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
                                  icon: HugeIcons.strokeRoundedVideo01,
                                  color: Colors.black,
                                  size: 50.0,
                                ),
                                spacer(),
                                ParagraphText("Select a video for the reel"),
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
                              itemCount: _videos.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          const Expanded(
                                            child: Center(
                                              child: Icon(
                                                Icons.play_circle_fill,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          ParagraphText(
                                            _videos[index].path.split('/').last,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    spacer1(),
                    TextForm(
                      label: "Reel Caption",
                      textEditingController: captionController,
                      lines: 5,
                      hint: "Write a short reel caption",
                    ),
                    spacer3(),
                    customButton(
                      loading: loading,
                      onTap: _uploadReel,
                      text: loading ? "" : "Add Reel",
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
