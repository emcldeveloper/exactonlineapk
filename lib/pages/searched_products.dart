import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/filter_tiles.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class SearchedProductsPage extends StatefulWidget {
  final String keyword;
  const SearchedProductsPage({super.key, required this.keyword});

  @override
  State<SearchedProductsPage> createState() => _SearchedProductsPageState();
}

class _SearchedProductsPageState extends State<SearchedProductsPage> {
  var loading = true.obs;
  Rx<List> products = Rx<List>([]);
  @override
  void initState() {
    trackScreenView("SearchedProductsPage");
    ProductController()
        .getProducts(
      page: 1,
      limit: 10,
      keyword: widget.keyword,
    )
        .then((res) {
      products.value = res;
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
        title: HeadingText(widget.keyword),
        centerTitle: true,
        actions: [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: GetX(
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
                    ? Center(
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesome.box_open_solid,
                                color: Colors.grey[500],
                                size: 50,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "No Products Found",
                                style: TextStyle(color: Colors.grey[600]),
                              )
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            spacer(),
                            const FilterTilesWidget(),
                            spacer(),
                            Expanded(
                              child: StaggeredGrid.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 10,
                                children: products.value
                                    .map((product) => ProductCard(
                                          isStagger: true,
                                          data: product,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      );
          }),
    );
  }
}
