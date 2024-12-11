import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/seller_reels.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> productItems = [
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/braids.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "Hand Jewelry",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/heinken.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "Pink Top",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/greenwatch.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "Smart Watch",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/jergens.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "Earrings",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/rays.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "Braids",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/kevita.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: mutedTextColor,
            size: 14.0,
          ),
        ),
        title: HeadingText("Shop Details"),
        centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.local_phone_outlined, color: Colors.black, size: 28),
              onPressed: () {
              },
            ),
            IconButton(
              icon: const Icon(Icons.message_outlined, color: Colors.black, size: 28),
              onPressed: () {},
            ),
          ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: primaryColor,
            height: 1.0,
          ),
        ),
      ),
        body: Column(
          children: [
            Row(
              children: [
                ClipOval(
                  child: Container(
                    height: 80,
                    width: 80,
                    child: Image.asset(
                      "assets/images/shop_image.png",
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Column(
                  children: [
                    HeadingText("Vunja bei shop"),
                    ParagraphText("Sinza, Dar es salaam, Tanzania"),
                    spacer(),
                    ParagraphText("Description", fontWeight: FontWeight.bold),
                    ParagraphText(
                        "Lorem feugiat amet semper varius  ipsum. Parturient aenrutrum tortor sempe...."),
                  ],
                )
              ],
            ),
            PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  labelColor: Colors.black,
                  unselectedLabelColor: mutedTextColor,
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
                    Tab(text: "Shop Products"),
                    Tab(text: "Reels"),
                  ],
                ),
              ),
            ),
            TabBarView(
              children: [
                // shop product Tab
                Column(
                  children: productItems.map((item) {
                    return HorizontalProductCard(data: item);
                  }).toList(),
                ),
                // reels Tab
                ProductMasonryGrid(productItems: productItems),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
