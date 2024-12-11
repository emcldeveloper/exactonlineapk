import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/add_product_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/horizontal_product_card.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyShopPage extends StatelessWidget {
  const MyShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tilesItems = [
      {'points': "248", 'title': "Impressions"},
      {'points': "88", 'title': "Clicks"},
      {'points': "49", 'title': "Shares"},
      {'points': "23", 'title': "Calls"},
      {'points': "982", 'title': "Likes"},
      {'points': "20", 'title': "Profile Views"},
    ];

    final List<Map<String, dynamic>> productItems = [
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/teal_tshirt.png",
        'description': "Short description of the product.",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/teal_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/red_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/black_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/green_tshirt.png",
        'description':
            "us elementum. Et ligula ornare tempor fermentum fringil vulputate mi dui. Massa ....",
        'rating': 4.5,
      },
    ];

    final navCategories = [
      "Shop Products",
      "Reels",
      "My Orders",
      "Promoted",
      "Ads",
    ];

    return DefaultTabController(
      length: navCategories.length,
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
          title: HeadingText("E-Online"),
          actions: [
            Icon(
              Icons.settings_outlined,
              size: 16.0,
            ),
            const SizedBox(width: 16),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black.withOpacity(0.5),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              indicatorColor: Colors.black,
              tabs: navCategories.map((category) {
                return Tab(text: category);
              }).toList(),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Metrics Tiles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: tilesItems.map((item) {
                  return Column(
                    children: [
                      ParagraphText(
                        item['points'],
                        fontWeight: FontWeight.bold,
                      ),
                      ParagraphText(item['title']),
                    ],
                  );
                }).toList(),
              ),
              spacer1(),
              customButton(
                onTap: () {
                  Get.to(() => const AddProductPage());
                },
                text: "Add New Product",
                vertical: 8.0,
              ),
              spacer1(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeadingText("My Products (${productItems.length})"),
                  const Icon(Icons.menu_open_sharp),
                ],
              ),
              spacer(),
              // TabBarView
              Expanded(
                child: TabBarView(
                  children: navCategories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: buildProductList(productItems),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProductList(List<Map<String, dynamic>> productItems) {
    return ListView.builder(
      itemCount: productItems.length,
      itemBuilder: (context, index) {
        return HorizontalProductCard(data: productItems[index]);
      },
    );
  }
}
