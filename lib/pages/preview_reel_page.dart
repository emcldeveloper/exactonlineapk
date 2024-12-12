import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreviewReelPage extends StatefulWidget {
  final Map<String, dynamic> reel;

  const PreviewReelPage({required this.reel, super.key});

  @override
  State<PreviewReelPage> createState() => _PreviewReelPageState();
}

class _PreviewReelPageState extends State<PreviewReelPage> {
  bool isBlockingReelVisible = false;

  void toggleBlockingReel() {
    setState(() {
      isBlockingReelVisible = !isBlockingReelVisible;
    });
  }

  void hideBlockingReel() {
    if (isBlockingReelVisible) {
      setState(() {
        isBlockingReelVisible = false;
      });
    }
  }

  void blockReel() {
    // Add logic to block the reel here
    print('Reel blocked');
    // Hide the container after blocking
    setState(() {
      isBlockingReelVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: InkWell(
        onTap: hideBlockingReel,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                (widget.reel['imageUrl'] as List<String>).isNotEmpty
                    ? (widget.reel['imageUrl'] as List<String>).first
                    : "assets/images/defaultImage.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: toggleBlockingReel,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.more_vert_sharp,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
              ),
            ),
            // The Block container
            if (isBlockingReelVisible)
              Positioned(
                top: 83,
                right: 16,
                child: GestureDetector(
                  onTap: blockReel,
                  child: Container(
                    width: 150.0,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Block this reel',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Content centered at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black,
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
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
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      AssetImage('assets/images/avatar.png'),
                                ),
                                const SizedBox(width: 8),
                                ParagraphText(
                                  widget.reel['title'] ?? 'Diana Mwakaponda',
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
                        widget.reel['description'] ??
                            "Lorem ipsum dolor sit amet consectetur. Gravida gravida duis mi teger tellus risus cursus. See More",
                        color: Colors.white,
                      ),
                      spacer1(),
                      // Action buttons
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.favorite_border,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
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
                                const Icon(
                                  Icons.comment,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                ParagraphText(
                                  '200',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                            const Icon(
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
            ),
          ],
        ),
      ),
    );
  }
}
