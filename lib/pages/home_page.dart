import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/pages/cart_page.dart';
import 'package:e_online/pages/notifications_page.dart';
import 'package:e_online/pages/profile_page.dart';
import 'package:e_online/pages/search_page.dart';
import 'package:e_online/pages/see_all_page.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  final List<String> carouselImages = [
    "assets/images/homePromo.png",
    "assets/images/homePromo.png",
    "assets/images/homePromo.png",
    "assets/images/homePromo.png",
  ];

  @override
  Widget build(BuildContext context) {
    final categories = [
      "All",
      "Electronics",
      "Accessories",
      "Clothes",
      "Decorations",
      "Appliances"
    ];

    List<Map<String, dynamic>> filterProducts(String category) {
      if (category == "All") return productItems;
      return productItems
          .where((product) =>
              (product['category'] ?? '').toLowerCase() ==
              category.toLowerCase())
          .toList();
    }

    Widget buildProductList(String category) {
      final filteredProducts = filterProducts(category);

      if (filteredProducts.isEmpty) {
        return Center(child: Text("No $category Available"));
      }

      return SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      initialPage: 0,
                      height: 160,
                      viewportFraction: 1,
                      onPageChanged: (value, _) {
                        setState(() {
                          _currentPage = value;
                        });
                      },
                    ),
                    items: carouselImages.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Image.asset(i, fit: BoxFit.contain);
                        },
                      );
                    }).toList(),
                  ),
                  spacer(),
                  carouselIndicator(),
                ],
              ),
              spacer1(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ParagraphText("New Arrival",
                                fontWeight: FontWeight.bold, fontSize: 15.0),
                            ParagraphText("Filtered products for you"),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(const SeeAllPage());
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: mutedTextColor,
                            size: 15,
                          ),
                        )
                      ],
                    ),
                    spacer1(),
                    SizedBox(
                      height: 230,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ParagraphText("For You",
                                fontWeight: FontWeight.bold, fontSize: 15.0),
                            ParagraphText("Filtered products for you"),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(const SeeAllPage());
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: mutedTextColor,
                            size: 15,
                          ),
                        )
                      ],
                    ),
                    spacer1(),
                    SizedBox(
                      height: 230,
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 2.0,
                        childAspectRatio: 0.70,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                            data: filteredProducts[index], height: 170);
                      },
                    ),
                    spacer(),
                  ],
                ),
              ),
            ],
          ),
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
          title: HeadingText("ExactOnline"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                tabAlignment: TabAlignment.start,
                dividerColor: const Color.fromARGB(255, 234, 234, 234),
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black.withOpacity(0.5),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
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
                            style: const TextStyle(fontSize: 15),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          actions: [
            InkWell(
                onTap: () {
                  Get.to(const CartPage());
                },
                child: const Icon(Icons.shopping_bag_outlined, size: 24)),
            const SizedBox(width: 8),
            InkWell(
                onTap: () {
                  Get.to(SearchPage());
                },
                child: const Icon(AntDesign.search_outline)),
            const SizedBox(width: 8),
            InkWell(
                onTap: () {
                  Get.to(const NotificationsPage());
                },
                child: const Icon(Icons.notifications_none_outlined)),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                Get.to(const ProfilePage());
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
            return buildProductList(category);
          }).toList(),
        ),
      ),
    );
  }

  carouselIndicator() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(carouselImages.length, (int number) => number++)
            .map((i) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: 7,
                width: i == _currentPage ? 15 : 7,
                color: i == _currentPage ? secondaryColor : const Color(0xffEBEBEB),
              ),
            ),
          );
        }).toList());
  }
}
