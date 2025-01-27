import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
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
          title: HeadingText("Reels"),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                labelColor: Colors.black,
                dividerColor: Color.fromARGB(255, 234, 234, 234),
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
                padding: EdgeInsets.symmetric(horizontal: 1),
                labelPadding: EdgeInsets.symmetric(horizontal: 16),
                tabs: [
                  Tab(text: "All"),
                  Tab(text: "Following"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            ProductMasonryGrid(),
            ReelsFollowingTab(),
          ],
        ),
      ),
    );
  }
}

class ProductMasonryGrid extends StatelessWidget {
  const ProductMasonryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ReelController().getReels(page: 1, limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No reels available."));
        }

        final List<Map<String, dynamic>> reels =
            (snapshot.data as List<dynamic>)
                .map((item) => item as Map<String, dynamic>)
                .toList();

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
                return ReelCard(data: reel);
              },
            ),
          ),
        );
      },
    );
  }
}

class ReelCard extends StatelessWidget {
  final Map<String, dynamic> data;

  ReelCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    // Extract shop data
    final shopData = data['Shop'] ?? {};
    print(shopData);
    final shopName = shopData['name'] ?? "No Name";
    final shopImage = shopData['image'];

    String formatDuration(String duration) {
      try {
        // Split the duration string into hours, minutes, and seconds
        final parts = duration.split(':');
        if (parts.length == 3) {
          final minutes = parts[1]; // Extract minutes
          final seconds = parts[2]; // Extract seconds
          return '$minutes:$seconds'; // Return formatted as MM:SS
        }
        return '00:00';
      } catch (e) {
        return '00:00';
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviewReelPage(reels: [data]),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: data['videoUrl'].isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: data['thumbnail'] ?? '',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Icon(
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
                  child: Text(
                    formatDuration(data['duration'] ?? '00:00'),
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
                  data['caption'] ?? 'No caption.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14,
                ),
                spacer(),
                // Shop Info and Likes
                Row(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: shopImage != null
                          ? NetworkImage(shopImage)
                          : const AssetImage('assets/images/avatar.png')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 8),
                    // Shopname
                    Expanded(
                      child: Text(
                        shopName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Likes
                    Row(
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedFavourite,
                          color: Colors.black,
                          size: 14.0,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data['likes'].toString(),
                          style: const TextStyle(
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
