import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/pages/preview_reel_page.dart';
import 'package:e_online/pages/search_page.dart';
import 'package:e_online/widgets/following.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

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
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black, size: 28),
              onPressed: () {
                 Get.to(SearchPage());
              },
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black, size: 28),
              onPressed: () {},
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.black,
                  ),
                  insets: EdgeInsets.symmetric(horizontal: 0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                labelPadding: EdgeInsets.only(right: 24, bottom: 8),
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
            // All Tab
            ProductMasonryGrid(productItems: productItems),
            // Following Tab

            ReelsFollowingTab(),
            // ProductMasonryGrid(
            //   productItems: productItems
            //       .where((item) => item['category'] == "Following")
            //       .toList(),
            // ),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 200),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: productItems.length,
          itemBuilder: (context, index) {
            return ReelCard(
              data: productItems[index],
              index: index,
            );
          },
        ),
      ),
    );
  }
}

class ReelCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;

  const ReelCard({
    required this.data,
    required this.index,
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
                      builder: (context) => PreviewReelPage(reel: data),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    (data['imageUrl'] as List<String>).isNotEmpty
                        ? (data['imageUrl'] as List<String>).first
                        : "assets/images/defaultImage.png", 
                    fit: BoxFit.cover,
                    height: index.isEven ? 280 : 200,
                  ),
                ),
              ),
              // Duration indicator
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      radius: 16,
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    SizedBox(width: 8),
                    // Username
                    Expanded(
                      child: Text(
                        'Diana Mwakaponda',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Likes
                    Row(
                      children: [
                        Icon(Icons.favorite_border, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '12k',
                          style: TextStyle(
                            fontSize: 14,
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
