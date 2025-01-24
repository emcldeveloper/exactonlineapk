import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/reel_controller.dart';
import 'package:e_online/pages/preview_reel_page.dart';
import 'package:e_online/widgets/following.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hugeicons/hugeicons.dart';

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          backgroundColor: mainColor,
          elevation: 0,
          title: HeadingText(
            "Reels",
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                labelColor: Colors.black,
                dividerColor: const Color.fromARGB(255, 234, 234, 234),
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.black,
                  ),
                  insets: EdgeInsets.symmetric(horizontal: 0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 1),
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: [
                  Tab(
                    text: "All",
                  ),
                  Tab(text: "Following"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // All Tab
            ProductMasonryGrid(productItems: productItems),
            // Following Tab
            ReelsFollowingTab(),
          ],
        ),
      ),
    );
  }
}

class ProductMasonryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> productItems;

  const ProductMasonryGrid({required this.productItems, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ReelController().getShopReels(page: 1, limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No reels available."));
        }

        final List reels = snapshot.data;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 200),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              itemCount: reels.length,
              itemBuilder: (context, index) {
                final reel = reels[index];

                // Check for 'ReelVideo' safely
                if (reel['ReelVideo'] != null && reel['ReelVideo'].isNotEmpty) {
                  return ReelCard(data: reel);
                } else {
                  return Container();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ConstrainedBox(
//         constraints:
//             BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 200),
//         child: MasonryGridView.count(
//           crossAxisCount: 2,
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           itemCount: productItems.length,
//           itemBuilder: (context, index) {
//             return ReelCard(
//               data: productItems[index],
//               index: index,
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

class ReelCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReelCard({
    required this.data,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video/Image Container with Duration
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PreviewReelPage(reels: [data, data]),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: data['ReelVideo'].isNotEmpty
                      ? Image.network(
                          data[
                              'thumbnailUrl'], // Ensure `thumbnailUrl` exists in your API response
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        )
                      : Icon(
                          Icons.videocam_off,
                          size: 100,
                          color: Colors.grey,
                        ),
                ),

                // child: ClipRRect(
                //   borderRadius: BorderRadius.circular(12),
                //   child: Image.asset(
                //     (data['imageUrl'] as List<String>).isNotEmpty
                //         ? (data['imageUrl'] as List<String>).first
                //         : "assets/images/defaultImage.png",
                //     fit: BoxFit.cover,
                //     height: index.isEven ? 280 : 200,
                //     width: double.infinity,
                //   ),
                // ),
              ),
              // Duration indicator
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '0:30',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParagraphText(
                  data['description'] ?? 'Lorem ipsum dolor sit amet constur.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14,
                ),
                spacer(),
                // User Info and Likes
                const Row(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    SizedBox(width: 8),
                    // Username
                    Expanded(
                      child: Text(
                        'Diana Mwakaponda',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Likes
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedFavourite,
                          color: Colors.black,
                          size: 14.0,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '12k',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
