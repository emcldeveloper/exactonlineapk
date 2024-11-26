import 'package:flutter/material.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';

class ImageEditBottomSheet extends StatelessWidget {
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  const ImageEditBottomSheet({
    Key? key,
    required this.onReplace,
    required this.onDelete,
  }) : super(key: key);

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
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: mutedTextColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                onReplace();
              },
              child: Row(
                children: [
                  const Icon(Icons.upload_file_outlined),
                  const SizedBox(width: 8),
                  ParagraphText("Change image file"),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
