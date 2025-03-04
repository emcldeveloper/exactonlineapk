import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/pages/search_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/favorite_card.dart';
import 'package:e_online/widgets/filter_tiles.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';

class ViewAllPage extends StatefulWidget {
  String keyword;
  ViewAllPage({super.key, required this.keyword});

  @override
  State<ViewAllPage> createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  var loading = true.obs;
  Rx<List> products = Rx<List>([]);
  @override
  void initState() {
    trackScreenView("ViewAllPage");
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
                              child: ListView.builder(
                                itemCount: products.value.length,
                                itemBuilder: (context, index) {
                                  final item = products.value[index];
                                  return FavoriteCard(data: item);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
          }),
    );
  }
}
