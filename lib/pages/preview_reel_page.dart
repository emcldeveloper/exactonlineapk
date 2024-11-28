import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreviewReelPage extends StatelessWidget {
  final Map<String, dynamic> reel;

  PreviewReelPage({required this.reel, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              reel['imageUrl'],
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Content centered at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: AssetImage(reel['imageUrl']),
                            ),
                            SizedBox(width: 8),
                            ParagraphText(
                              reel['title'] ?? 'Diana Mwakaponda',
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: ParagraphText(
                          "Follow",
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  spacer1(),
                  // Reel description
                  ParagraphText(
                    reel['description'] ??
                        "Lorem ipsum dolor sit amet consectetur. Gravida gravida duis mi teger tellus risus cursus. See More",
                    color: Colors.white,
                  ),
                  spacer1(),
                  // Action buttons
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            ParagraphText(
                              '12k',
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.comment,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            ParagraphText(
                              '200',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        Icon(
                          Icons.share,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
