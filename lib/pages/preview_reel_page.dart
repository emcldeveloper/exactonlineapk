import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/blocking_reel.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:video_player/video_player.dart';

class PreviewReelPage extends StatefulWidget {
  final List<Map<String, dynamic>> reels;

  const PreviewReelPage({required this.reels, super.key});

  @override
  State<PreviewReelPage> createState() => _PreviewReelPageState();
}

class _PreviewReelPageState extends State<PreviewReelPage> {
  bool isBlockingReelVisible = false;
  late PageController _pageController;
  late VideoPlayerController _videoController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeVideoPlayer(widget.reels[currentIndex]['videoUrl']);
  }

  void _initializeVideoPlayer(String videoUrl) {
    _videoController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
        _videoController.setLooping(true);
      });
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
      _videoController.dispose();
      _initializeVideoPlayer(widget.reels[index]['videoUrl']);
    });
  }

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

  void _showBlockingReasonsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const BlockingReel(),
      ),
    );
  }

  void blockReel() {
    // Add logic to block the reel here
    _showBlockingReasonsBottomSheet();
    setState(() {
      isBlockingReelVisible = false;
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.reels.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final reel = widget.reels[index];
          return Stack(
            children: [
              // Video Player
              Positioned.fill(
                child: _videoController.value.isInitialized
                    ? VideoPlayer(_videoController)
                    : Center(
                        child: CircularProgressIndicator(
                        color: Colors.white,
                      )),
              ),
              // Back Button
              Positioned(
                top: 40,
                left: 16,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Center(
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Blocking Options
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
                      size: 22.0,
                    ),
                  ),
                ),
              ),
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
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedSquareLock02,
                            color: Colors.black,
                            size: 22.0,
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
              // Reel Details
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
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      AssetImage('assets/images/avatar.png'),
                                ),
                                const SizedBox(width: 8),
                                ParagraphText(
                                  reel['title'] ?? 'Default User',
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
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
                        ParagraphText(
                          reel['description'] ??
                              "Lorem ipsum dolor sit amet consectetur.",
                          color: Colors.white,
                        ),
                        spacer1(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            color: Colors.black45,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 70, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedFavourite,
                                        color: Colors.white,
                                        size: 22.0,
                                      ),
                                      const SizedBox(width: 4),
                                      ParagraphText(
                                        '12k',
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const HugeIcon(
                                        icon: HugeIcons.strokeRoundedComment01,
                                        color: Colors.white,
                                        size: 22.0,
                                      ),
                                      const SizedBox(width: 4),
                                      ParagraphText(
                                        '200',
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedShare01,
                                    color: Colors.white,
                                    size: 22.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        spacer2(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
