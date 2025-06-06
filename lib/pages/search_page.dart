// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/categories_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/pages/categories_products_page.dart';
import 'package:e_online/pages/searched_products.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:e_online/widgets/search_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<Map<String, dynamic>> searchKeywords = [
    {'name': 'Samsung Television', 'date': '10/11/2024'},
    {'name': 'router tplink', 'date': '10/11/2024'},
    {'name': 'sneakers', 'date': '10/11/2024'},
  ];

  Rx<List> categories = Rx<List>([]);
  Rx<List> products = Rx<List>([]);

  @override
  void initState() {    
    trackScreenView("SearchPage");
    // TODO: implement initState
    CategoriesController()
        .getCategories(page: 1, limit: 10, keyword: "")
        .then((res) {
      print(res);
      categories.value = res;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: mainColor,
          elevation: 0,
          leadingWidth: 20,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: mutedTextColor,
                size: 16.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: buildSearchBar(onChanged: (value) {
            // print(value ?? "none");

            ProductController()
                .getSearchProducts(keyword: value.isEmpty ? "none" : value)
                .then((res) {
              products.value = res ?? "";
            });
          }),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color.fromARGB(255, 242, 242, 242),
              height: 1.0,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetX<CategoriesController>(
                  init: CategoriesController(),
                  builder: (context) {
                    return categories.value.isEmpty
                        ? const Center(
                            child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ))
                        : products.value.isNotEmpty
                            ? Column(
                                children: [
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: products.value.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: GestureDetector(
                                            onTap: () {
                                              Get.to(() => SearchedProductsPage(
                                                  keyword: products.value[index]
                                                      ["name"]));
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.search,
                                                  size: 18,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                ParagraphText(
                                                    fontWeight: FontWeight.bold,
                                                    products.value[index]
                                                        ["name"]),
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ParagraphText("Categories",
                                      fontWeight: FontWeight.bold),
                                  spacer(),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: categories.value.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CategoriesProductsPage(
                                                category:
                                                    categories.value[index],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: primaryColor,
                                              ),
                                              child: categories.value[index]
                                                          ['image'] !=
                                                      null
                                                  ? CachedNetworkImage(
                                                      imageUrl: categories
                                                              .value[index]
                                                          ['image'],
                                                      fit: BoxFit.contain,
                                                    )
                                                  : const Center(
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                            ),
                                            spacer(),
                                            ParagraphText(
                                              categories.value[index]['name'],
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12.0,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
