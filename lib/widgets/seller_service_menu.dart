import 'package:e_online/controllers/service_controller.dart';
import 'package:e_online/pages/edit_service_page.dart';
import 'package:e_online/utils/snackbars.dart';
import 'package:e_online/widgets/comingSoon.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/popup_alert.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:get/get.dart';

class ServiceEditBottomSheet extends StatefulWidget {
  var selectedService;
  final VoidCallback onView;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  ServiceEditBottomSheet({
    super.key,
    required this.selectedService,
    required this.onView,
    required this.onReplace,
    required this.onDelete,
  });

  @override
  State<ServiceEditBottomSheet> createState() => _ServiceEditBottomSheetState();
}

class _ServiceEditBottomSheetState extends State<ServiceEditBottomSheet> {
  @override
  Widget build(BuildContext context) {
    bool isSwitched = false;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            spacer1(),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 228, 228, 228),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            spacer1(),
            Row(
              children: [
                HeadingText("Settings"),
              ],
            ),
            // GestureDetector(
            //   onTap: () {
            //     Get.to(const PromoteServiceInsightsBottomSheet());
            //   },
            //   child: Row(
            //     children: [
            //       const Icon(Icons.upload_file_outlined),
            //       const SizedBox(width: 8),
            //       ParagraphText("Service insights"),
            //     ],
            //   ),
            // ),
            spacer1(),
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await Get.to(() => EditServicePage(
                      service: widget.selectedService,
                    ));
                widget.onDelete();
              },
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined),
                  const SizedBox(width: 8),
                  ParagraphText("Edit Service"),
                ],
              ),
            ),
            spacer1(),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                showPopupAlert(
                  context,
                  iconAsset: "assets/images/closeicon.jpg",
                  heading: "Delete",
                  text: "Are you sure you want to delete?",
                  button1Text: "No",
                  button1Action: () {
                    Get.back();
                  },
                  button2Text: "Yes",
                  button2Action: () async {
                    ServiceController()
                        .deleteService(widget.selectedService["id"])
                        .then((res) {
                      Get.back();
                      showSuccessSnackbar(
                          title: "Deleted successfully",
                          description: "Service is deleted succesfully");
                      widget.onDelete();
                    });
                  },
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.delete_outline),
                  const SizedBox(width: 8),
                  ParagraphText("Delete Service"),
                ],
              ),
            ),
            spacer1(),
          ],
        ),
      ),
    );
  }
}
