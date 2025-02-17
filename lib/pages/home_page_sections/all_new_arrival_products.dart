import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/favorite_card.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllNewArrivalProducts extends StatefulWidget {
  const AllNewArrivalProducts({super.key});

  @override
  State<AllNewArrivalProducts> createState() => _AllNewArrivalProductsState();
}

class _AllNewArrivalProductsState extends State<AllNewArrivalProducts> {
  Rx<List> products = Rx<List>([]);
  @override
  void initState() {
    ProductController()
        .getNewProducts(page: 1, limit: 20, keyword: "")
        .then((res) {
      products.value =
          res.where((item) => item["ProductImages"].length > 0).toList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: HeadingText("New Arrival"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: Obx(
        () => products.value.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.black,
              ))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  child: ListView.builder(
                    itemCount: products.value.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: FavoriteCard(data: products.value[index]),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
