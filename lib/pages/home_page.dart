import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/profile_page.dart';
import 'package:e_online/pages/search_page.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final List<Map<dynamic, dynamic>> productItems = [
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': [
          "assets/images/coloredTop.png",
          "assets/images/coloredTop.png",
          "assets/images/coloredTop.png",
          "assets/images/coloredTop.png",
        ],
        'category': "clothes",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': [
          "assets/images/handJewerly.png",
          "assets/images/handJewerly.png",
          "assets/images/handJewerly.png",
          "assets/images/handJewerly.png",
        ],
        'category': "Accessories",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': [
          "assets/images/pinkTop.png",
          "assets/images/pinkTop.png",
          "assets/images/pinkTop.png",
          "assets/images/pinkTop.png",
        ],
        'category': "clothes",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': [
          "assets/images/earrings.png",
          "assets/images/earrings.png",
          "assets/images/earrings.png",
          "assets/images/earrings.png",
        ],
        'category': "Accessories",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': [
          "assets/images/braids.png",
          "assets/images/braids.png",
          "assets/images/braids.png",
        ],
        'category': "Decorations",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': [
          "assets/images/watch.png",
          "assets/images/watch.png",
          "assets/images/watch.png",
        ],
        'category': "Electronics",
        'rating': 4.5,
      },
    ];

    final categories = [
      "All",
      "Electronics",
      "Accessories",
      "Clothes",
      "Decorations",
      "Appliances"
    ];

    List<Map<dynamic, dynamic>> filterProducts(String category) {
      if (category == "All") return productItems;
      return productItems
          .where((product) =>
              product['category'].toLowerCase() == category.toLowerCase())
          .toList();
    }

    Widget buildProductList(String category) {
      final filteredProducts = filterProducts(category);

      if (filteredProducts.isEmpty) {
        return Center(child: Text("No $category Available"));
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            spacer1(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeadingText("New Arrival"),
                ParagraphText(
                  "See All",
                  color: mutedTextColor,
                  decoration: TextDecoration.underline,
                ),
              ],
            ),
            spacer1(),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: ProductCard(data: filteredProducts[index]),
                  );
                },
              ),
            ),
            spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeadingText("For You"),
                ParagraphText(
                  "See All",
                  color: mutedTextColor,
                  decoration: TextDecoration.underline,
                ),
              ],
            ),
            spacer1(),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: ProductCard(data: filteredProducts[index]),
                  );
                },
              ),
            ),
            spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeadingText("All Products"),
                ParagraphText(
                  "See All",
                  color: mutedTextColor,
                  decoration: TextDecoration.underline,
                ),
              ],
            ),
            spacer1(),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.65,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(data: filteredProducts[index]);
              },
            ),
            spacer(),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          backgroundColor: mainColor,
          elevation: 0,
          title: HeadingText("E-Online"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black.withOpacity(0.5),
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 1),
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: categories
                    .map((category) => Tab(
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Get.to(SearchPage());
              },
              icon: Icon(Icons.search),
            ),
            GestureDetector(
              onTap: () {
                Get.to(ProfilePage());
              },
              child: ClipOval(
                child: Container(
                  height: 30,
                  width: 30,
                  color: secondaryColor,
                  child: Image.asset(
                    "assets/images/avatar.png",
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: TabBarView(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: buildProductList(category),
            );
          }).toList(),
        ),
      ),
    );
  }
}
