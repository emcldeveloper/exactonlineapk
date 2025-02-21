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
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class PreviewReelPage extends StatefulWidget {
  final List<Map<String, dynamic>> reels;

  const PreviewReelPage({required this.reels, super.key});

  @override
  State<PreviewReelPage> createState() => _PreviewReelPageState();
}

class _PreviewReelPageState extends State<PreviewReelPage> {
  bool isBlockingReelVisible = false;
  final isLoading = true.obs;
  late PageController _pageController;
  late VideoPlayerController _videoController =
      VideoPlayerController.networkUrl(Uri(path: ""));
  int currentIndex = 0;
  final UserController userController = Get.find();
  final ReelController reelController = Get.put(ReelController());
  final FollowingController followingController =
      Get.put(FollowingController());
  String userId = "";
  Rx<Map<String, dynamic>> reelDetails = Rx<Map<String, dynamic>>({});
  RxBool isLiked = false.obs;
  bool? isFollowing;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    userId = userController.user.value['id'] ?? "";
    _initializeReelDetails(widget.reels[currentIndex]['id']);
    ever(reelDetails, (value) {
      print('Reel details updated: $value');
    });
    _sendReelStats("view");
  }

  Future<void> _initializeReelDetails(String reelId) async {
    try {
      final details = await reelController.getSpecificReels(
        selectedId: reelId,
        page: 1,
        limit: 20,
      );
      reelDetails.value = details;
      _initializeVideoPlayer(reelDetails.value['videoUrl']);
      isFollowing = reelDetails.value['Shop']['following'] ?? false;
      isLiked.value = reelDetails.value['Shop']['liked'] ?? false;
      isLoading.value = false;
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
    });
    _initializeReelDetails(widget.reels[index]['id']).then((_) {
      _initializeVideoPlayer(reelDetails.value['videoUrl']);
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
    var payload = {
      "ShopId": shop['id'],
      "UserId": userId,
    };

    try {
      var result = await followingController.followShop(payload);
      if (result != null) {
        setState(() {
          isFollowing = true;
        });
      }
    } catch (e) {
      print("Error following shop: $e");
    }
  }

  Future<void> _sendReelStats(String type) async {
    var reelId = widget.reels[currentIndex]['id'];
    var payload = {"ReelId": reelId, "UserId": userId, "type": type};
    try {
      if (type == "like") {
        var reelStatsList = reelDetails.value['ReelStats'] ?? [];
        if (isLiked.value) {
          Map<String, dynamic>? matchingStats = reelStatsList.firstWhere(
            (stats) =>
                stats['ReelId'] == reelId &&
                stats['UserId'] == userId &&
                stats['type'] == "like",
            orElse: () => null,
          );

          if (matchingStats != null) {
            var reelStatsId = matchingStats['id'];
            await reelController.deleteReelStats(reelStatsId);
            isLiked.value = false;
            reelDetails.update((reel) {
              if (reel != null) reel['likes'] = (reel['likes'] ?? 0) - 1;
            });
            debugPrint("Unlike Success!");
          } else {
            debugPrint("Error: No 'like' entry found to delete.");
          }
        } else {
          await reelController.addReelStats(payload);
          isLiked.value = true;
          reelDetails.update((reel) {
            if (reel != null) reel['likes'] = (reel['likes'] ?? 0) + 1;
          });
        }
      } else {
        await reelController.addReelStats(payload);
      }
    } catch (e) {
      debugPrint("Error updating reel stats: $e");
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(
        () => isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: widget.reels.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final shopData = reelDetails.value['Shop'] ?? {};
                    final shopName = shopData['name'] ?? "No Name";
                    final shopImage = shopData['shopImage'];

                    final reel = reelDetails.value;
                    return Stack(
                      children: [
                        // Video Player
                        Positioned.fill(
                          child: _videoController.value.isInitialized
                              ? VideoPlayer(_videoController)
                              : Center(
                                  child: _videoController.value.hasError
                                      ? const Text(
                                          "Failed to load video",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      : const CircularProgressIndicator(
                                          color: Colors.white),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SellerProfilePage(
                                                shopId: shopData['id'],
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
                                      isFollowing == true
                                          ? const SizedBox.shrink()
                                          : TextButton(
                                              onPressed: followShop,
                                              child: ParagraphText(
                                                "Follow",
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
                                                GestureDetector(
                                                  onTap: () {
                                                    _sendReelStats("like");
                                                  },
                                                  child: Obx(() => isLiked.value
                                                      ? Icon(
                                                          Icons.favorite,
                                                          color: Colors.red,
                                                        )
                                                      : Icon(
                                                          HugeIcons
                                                              .strokeRoundedFavourite,
                                                          color: Colors.white,
                                                          size: 22.0,
                                                        )),
                                                ),
                                                const SizedBox(width: 4),
                                                Obx(() => ParagraphText(
                                                      (reelDetails.value['Shop']
                                                                  ['likes'] ??
                                                              0)
                                                          .toString(),
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const HugeIcon(
                                                  icon: HugeIcons
                                                      .strokeRoundedComment01,
                                                  color: Colors.white,
                                                  size: 22.0,
                                                ),
                                              ],
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                // Make onTap async
                                                try {
                                                  await _sendReelStats("share");
                                                  String videoUrl = reelDetails
                                                          .value['videoUrl'] ??
                                                      '';
                                                  if (videoUrl.isNotEmpty) {
                                                    await Share.share(
                                                        "Check out this awesome reel: $videoUrl");
                                                  } else {
                                                    await Share.share(
                                                        "Check out this reel!");
                                                  }
                                                } catch (e) {
                                                  debugPrint(
                                                      "Error sharing reel: $e");
                                                }
                                              },
                                              child: const HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedShare01,
                                                color: Colors.white,
                                                size: 22.0,
                                              ),
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
                  });
                },
              ),
      ),
    );
  }
}
