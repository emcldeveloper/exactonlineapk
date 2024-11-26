import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreviewReelPage extends StatelessWidget {
  const PreviewReelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                ),
                child: Icon(Icons.arrow_back_ios_new_outlined,
                    color: Colors.white)),
          ),
          Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(data['imageUrl']),
              ),
              SizedBox(width: 8),
              // Username
              Expanded(
                child: Text(
                  'Diana Mwakaponda',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Likes
             ParagraphText("Follow"),
            ],
          ),
          ParagraphText(
              "Lorem ipsum dolor sit amet consectetur. Gravida gravida duis mi teger tellus risus cursus. See More"),
          spacer(),
          Container(
            decoration: BoxDecoration(
              color: secondaryColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 20),
                    SizedBox(width: 4),
                    Text(
                      '12k',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 20),
                    SizedBox(width: 4),
                    Text(
                      '200',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.favorite_border, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
