import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:hugeicons/hugeicons.dart';

class ImageEditBottomSheet extends StatelessWidget {
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  const ImageEditBottomSheet({
    super.key,
    required this.onReplace,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                color: mutedTextColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            spacer1(),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                onReplace();
              },
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedUpload01,
                    color: Colors.black,
                    size: 20.0,
                  ),
                  const SizedBox(width: 8),
                  ParagraphText("Change image file"),
                ],
              ),
            ),
            spacer1(),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
              child: Row(
                children: [
                  const Icon(Icons.delete_outline),
                  const SizedBox(width: 8),
                  ParagraphText("Delete product image"),
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
