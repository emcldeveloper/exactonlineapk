import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/following_controller.dart';
import 'package:e_online/controllers/reel_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/seller_profile_page.dart';
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
  final UserController userController = Get.find();
  final ReelController reelController = Get.put(ReelController());
  final FollowingController followingController =
      Get.put(FollowingController());
  String userId = "";
  Rx<Map<String, dynamic>> reelDetails = Rx<Map<String, dynamic>>({});

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    userId = userController.user['id'] ?? "";
    _initializeReelDetails(widget.reels[currentIndex]['id']);
    _initializeVideoPlayer(widget.reels[currentIndex]['videoUrl']);
  }

  Future<void> _initializeReelDetails(String reelId) async {
    try {
      reelDetails.value = await reelController.getSpecificReels(
        selectedId: reelId,
        page: 1,
        limit: 20,
      );
      setState(() {});
      print("maandazi");
      print(reelDetails.value);
      print("sambusa");
    } catch (e) {
      print("Error fetching reel details: $e");
    }
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
      _initializeReelDetails(widget.reels[index]['id']);
      _initializeVideoPlayer(widget.reels[index]['videoUrl']);
    });
  }

  void toggleBlockingReel() {
    setState(() {
      isBlockingReelVisible = !isBlockingReelVisible;
    });
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
    _showBlockingReasonsBottomSheet();
    setState(() {
      isBlockingReelVisible = false;
    });
  }

  Future<void> followShop() async {
    final shop = reelDetails.value['Shop'];
    // Unfollow example
    // followingController.deleteFollowing(followingId);
    if (shop == null) return;

    bool isFollowing = shop["following"] ?? false;
    if (isFollowing) return;

    try {
      var payload = {
        "ShopId": shop['id'],
        "UserId": userId,
      };

      await followingController.followShop(payload);
      setState(() {
        shop["following"] = true;
      });
    } catch (e) {
      print("Error following shop: $e");
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopData = reelDetails.value['Shop'] ?? {};
    final shopName = shopData['name'] ?? "No Name";
    final shopImage = shopData['image'];

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
                        child: _videoController.value.hasError
                            ? Text(
                                "Failed to load video",
                                style: TextStyle(color: Colors.white),
                              )
                            : CircularProgressIndicator(color: Colors.white),
                      ),
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
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 16.0,
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
                        // Shop info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SellerProfilePage(
                                      name: shopName,
                                      followers: shopData['followers'] ?? 0,
                                      imageUrl: shopImage,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundImage: shopImage != null
                                        ? NetworkImage(shopImage)
                                        : const AssetImage(
                                                'assets/images/avatar.png')
                                            as ImageProvider,
                                  ),
                                  const SizedBox(width: 8),
                                  ParagraphText(
                                    shopName,
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: followShop,
                              child: ParagraphText(
                                    reel["following"] ? "Unfollow" : "Follow",
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        ParagraphText(
                          reel['caption'] ?? "No caption.",
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
                                        reel['likes'].toString(),
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
                                        reel['views'].toString(),
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
