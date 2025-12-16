import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/reel_controller.dart';
import 'package:e_online/pages/add_reel_page.dart';
import 'package:e_online/pages/preview_reel_page.dart';
import 'package:e_online/pages/seller_profile_page.dart';
import 'package:e_online/widgets/following.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopReels extends StatelessWidget {
  const ShopReels({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Reels",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Get.to(() => const AddReelPage());
            },
          ),
        ],
      ),
      body: ShopMasonryGrid(),
    );
  }
}

class ShopMasonryGrid extends StatelessWidget {
  const ShopMasonryGrid({super.key});

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

        final List<Map<String, dynamic>> reels =
            (snapshot.data as List<dynamic>)
                .map((item) => item as Map<String, dynamic>)
                .toList();

        return reels.isEmpty
            ? noData()
            : Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.48,
                  ),
                  itemCount: reels.length,
                  itemBuilder: (context, index) {
                    final reel = reels[index];
                    return ReelCard(data: reel);
                  },
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
    final shopData = data['Shop'] ?? {};
    print(shopData);
    final shopName = shopData['name'] ?? "No Name";
    final shopImage = shopData['shopImage'];

    String formatDuration(String duration) {
      try {
        final parts = duration.split(':');
        if (parts.length == 3) {
          final minutes = parts[1];
          final seconds = parts[2];
          return '$minutes:$seconds';
        }
        return '00:00';
      } catch (e) {
        return '00:00';
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                      builder: (context) => PreviewReelPage(reel: data),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: data['videoUrl'].isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: data['thumbnail'] ?? '',
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            height: 220,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          height: 220,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.videocam_off,
                            size: 50,
                            color: Colors.grey,
                          ),
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
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    formatDuration(data['duration'] ?? '00:00'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['caption'] ?? 'No caption.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Shop Info and Likes
                Row(
                  children: [
                    // Profile Picture
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SellerProfilePage(
                                shopId: shopData['id'],
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: shopImage != null
                                  ? NetworkImage(shopImage)
                                  : const AssetImage('assets/images/avatar.png')
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 8),
                            // Shopname
                            Flexible(
                              child: Text(
                                shopName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Likes
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 14.0,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data['likes'].toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
