// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/reel_controller.dart';
import 'package:e_online/pages/preview_reel_page.dart';
import 'package:e_online/pages/seller_profile_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/following.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// ReelsPage remains unchanged
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
          leading: Container(),
          leadingWidth: 1.0,
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

class ProductMasonryGrid extends StatefulWidget {
  const ProductMasonryGrid({super.key});

  @override
  State<ProductMasonryGrid> createState() => _ProductMasonryGridState();
}

class _ProductMasonryGridState extends State<ProductMasonryGrid> {
  final RxList<Map<String, dynamic>> reels = <Map<String, dynamic>>[].obs;
  final ScrollController _scrollController = ScrollController();
  final RxInt _currentPage = 1.obs;
  final int _limit = 10;
  final RxBool _isLoading = false.obs;
  final RxBool _hasMore = true.obs;

  @override
  void initState() {
    super.initState();
    trackScreenView("ReelsPage");
    _fetchReels(_currentPage.value);
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchReels(int page) async {
    if (_isLoading.value || !_hasMore.value) return;

    _isLoading.value = true;

    try {
      final res = await ReelController().getReels(page: page, limit: _limit);
      final newReels = (res as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      if (newReels.isEmpty || newReels.length < _limit) {
        _hasMore.value = false;
      }

      if (page == 1) {
        reels.value = newReels;
      } else {
        reels.addAll(newReels);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reels: $e')),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading.value &&
        _hasMore.value) {
      _currentPage.value++;
      _fetchReels(_currentPage.value);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => reels.isEmpty && _isLoading.value
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
          : reels.isEmpty
              ? const Center(child: Text("No reels available."))
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 16,
                      children: [
                        ...reels.map((reel) => ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 200,
                                maxHeight: double.infinity,
                              ),
                              child: ReelCard(data: reel),
                            )),
                        if (_isLoading.value) ...[
                          for (var i = 0; i < 2; i++)
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.black),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}

// ReelCard remains unchanged
class ReelCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReelCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final shopData = data['Shop'] ?? {};
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
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.videocam_off,
                          size: 100,
                          color: Colors.grey,
                        ),
                ),
              ),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                Row(
                  children: [
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
                              radius: 12,
                              backgroundImage: shopImage != null
                                  ? NetworkImage(shopImage)
                                  : const AssetImage('assets/images/avatar.png')
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                shopName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_border,
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
