import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/pages/search_page.dart';
import 'package:e_online/widgets/favorite_card.dart';
import 'package:e_online/widgets/filter_tiles.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';

class CategoriesProductsPage extends StatefulWidget {
  var category;

  CategoriesProductsPage({super.key, required this.category});

  @override
  State<CategoriesProductsPage> createState() => _CategoriesProductsPageState();
}

class _CategoriesProductsPageState extends State<CategoriesProductsPage> {
  var loading = true.obs;
  Rx<List> products = Rx<List>([]);

  @override
  void initState() {
    print(widget.category["id"]);
    ProductController()
        .getProducts(
            page: 1, limit: 10, keyword: "", category: widget.category["id"])
        .then((res) {
      products.value = res;
      print("products.value");
      print(products.value);
      loading.value = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: mutedTextColor,
            size: 14.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: HeadingText(widget.category["name"]),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: GetX<ProductController>(
          init: ProductController(),
          builder: (context) {
            return loading.value
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    ),
                  )
                : products.value.isEmpty
                    ? noData()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                            itemCount: products.value.length,
                            itemBuilder: (context, index) {
                              return FavoriteCard(data: products.value[index]);
                            }),
                      );
          }),
    );
  }
}
