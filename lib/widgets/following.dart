import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/following_controller.dart';
import 'package:e_online/pages/seller_profile_page.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class ReelsFollowingTab extends StatefulWidget {
  @override
  _ReelsFollowingTabState createState() => _ReelsFollowingTabState();
}

class _ReelsFollowingTabState extends State<ReelsFollowingTab> {
  final FollowingController followingController =
      Get.put(FollowingController());
  RxList<Map<String, dynamic>> profiles = RxList<Map<String, dynamic>>([]);
  var loading = true.obs;
  @override
  void initState() {
    super.initState();
    _initializeFollowingDetails();
  }

  Future<void> _initializeFollowingDetails() async {
    try {
      final details = await followingController.getShopsFollowing(
        page: 1,
        limit: 20,
      );

      // Map API data into profiles list
      profiles.value = details.map<Map<String, dynamic>>((shop) {
        return {
          'id': shop['id'],
          'name': shop['name'] ?? 'No Name',
          'followers': '${shop['followers']} followers',
          'imageUrl':
              shop['shopImage'] ?? 'assets/images/avatar.png', 
        };
      }).toList();
      loading.value = false;
    } catch (e) {
      print("Error fetching reel details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show a loading indicator if profiles are empty
      if (loading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        );
      }

      return profiles.isEmpty
          ? noData()
          : Container(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellerProfilePage(
                            shopId: profile['id'],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: profile['imageUrl'] != null &&
                                  profile['imageUrl'].isNotEmpty
                              ? Image.network(
                                  profile['imageUrl'],
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return ClipOval(
                                      child: HugeIcon(
                                        icon: HugeIcons.strokeRoundedUserCircle,
                                        color: Colors.black,
                                        size: 80,
                                      ),
                                    );
                                  },
                                )
                              : HugeIcon(
                                  icon: HugeIcons.strokeRoundedUserCircle,
                                  color: Colors.black,
                                  size: 80,
                                ),
                        ),
                        spacer(),
                        ParagraphText(
                          profile['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          fontSize: 14.0,
                        ),
                        spacer(),
                        ParagraphText(
                          profile['followers'],
                          color: mutedTextColor,
                          textAlign: TextAlign.center,
                          fontSize: 12.0,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
    });
  }
}
