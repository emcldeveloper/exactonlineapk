import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/cart_products_controller.dart';
import 'package:e_online/controllers/categories_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/cart_page.dart';
import 'package:e_online/pages/home_page_sections/all_for_you_products.dart';
import 'package:e_online/pages/home_page_sections/all_new_arrival_products.dart';
import 'package:e_online/pages/home_page_sections/all_products.dart';
import 'package:e_online/pages/home_page_sections/for_you_products.dart';
import 'package:e_online/pages/home_page_sections/home_categories_products.dart';
import 'package:e_online/pages/home_page_sections/new_arrival_products.dart';
import 'package:e_online/pages/notifications_page.dart';
import 'package:e_online/pages/profile_page.dart';
import 'package:e_online/pages/search_page.dart';
import 'package:e_online/pages/see_all_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/ads_carousel.dart';
import 'package:e_online/widgets/cartIcon.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserController userController = Get.find();
  int _currentPage = 0;
  final List<String> carouselImages = [
    "assets/ads/ad1.jpg",
    "assets/ads/ad2.jpg",
    "assets/ads/ad3.jpg",
    "assets/ads/ad4.jpg",
  ];
  Rx<List> categories = Rx<List>([]);
  CartProductController cartProductController = CartProductController();
  @override
  void initState() {
    Get.put(cartProductController);
    CategoriesController()
        .getCategories(page: 1, limit: 50, keyword: "")
        .then((res) {
      print(res);
      categories.value = [
        {"id": "All", "name": "All"}
      ];
      categories.value.addAll(res);
    });
    super.initState();
    trackScreenView("HomePage");
  }

  @override
  Widget build(BuildContext context) {
    var avatar = userController.user.value["image"];
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

      return categories.value.length < 1
          ? CircularProgressIndicator(
              color: Colors.black,
            )
          : SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdsCarousel(),
                    spacer1(),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ParagraphText("New Arrival",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(const AllNewArrivalProducts());
                                },
                                child: ParagraphText(
                                  "See All",
                                  color: mutedTextColor,
                                  decoration: TextDecoration.underline,
                                ),
                              )
                            ],
                          ),
                        ),
                        spacer1(),
                        NewArrivalProducts(),
                        Container(
                          height: 8,
                          width: double.infinity,
                          color: const Color.fromARGB(255, 242, 242, 242),
                        ),
                        spacer1(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ParagraphText("For You",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(const AllForYouProducts());
                                },
                                child: ParagraphText(
                                  "See All",
                                  color: mutedTextColor,
                                  decoration: TextDecoration.underline,
                                ),
                              )
                            ],
                          ),
                        ),
                        spacer1(),
                        ForYouProducts(),
                        Container(
                          height: 8,
                          width: double.infinity,
                          color: const Color.fromARGB(255, 242, 242, 242),
                        ),
                        spacer1(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              HeadingText("All Products"),
                            ],
                          ),
                        ),
                        spacer1(),
                        AllProducts(),
                        spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            );
    }

    return GetX<CategoriesController>(
        init: CategoriesController(),
        builder: (find) {
          return DefaultTabController(
            length: categories.value.length,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: mainColor,
                elevation: 0,
                leading: Container(),
                leadingWidth: 1.0,
                title: HeadingText("ExactOnline"),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Builder(builder: (context) {
                      return TabBar(
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
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        tabs: categories.value
                            .map((category) => Tab(
                                  child: Text(
                                    category["name"],
                                    style: GoogleFonts.outfit(fontSize: 15),
                                  ),
                                ))
                            .toList(),
                      );
                    }),
                  ),
                ),
                actions: [
                  cartIcon(),
                  const SizedBox(width: 8),
                  InkWell(
                      onTap: () {
                        Get.to(SearchPage());
                      },
                      child: const Icon(
                        Bootstrap.search,
                        color: Colors.black,
                        size: 20.0,
                      )),
                  const SizedBox(width: 12),
                  InkWell(
                      onTap: () {
                        Get.to(NotificationsPage());
                      },
                      child: const Icon(
                        Bootstrap.bell,
                        color: Colors.black,
                        size: 20.0,
                      )),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      Get.to(const ProfilePage());
                    },
                    child: ClipOval(
                      child: avatar != null
                          ? CachedNetworkImage(
                              imageUrl: avatar,
                              height: 30,
                              width: 30,
                              fit: BoxFit.cover,
                            )
                          : HugeIcon(
                              icon: HugeIcons.strokeRoundedUserCircle,
                              color: Colors.black,
                              size: 30,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              body: categories.value.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.black,
                    ))
                  : TabBarView(
                      children: categories.value.map((category) {
                        return category["id"] == "All"
                            ? buildProductList(category["id"])
                            : Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: HomeCategoriesProducts(
                                  category: category["id"],
                                ),
                              );
                      }).toList(),
                    ),
            ),
          );
        });
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
                color: i == _currentPage
                    ? secondaryColor
                    : const Color(0xffEBEBEB),
              ),
            ),
          );
        }).toList());
  }
}
