import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';

import '../../widgets/shop_product_card.dart';

class ShopProducts extends StatefulWidget {
  const ShopProducts({super.key});

  @override
  State<ShopProducts> createState() => _ShopProductsState();
}

class _ShopProductsState extends State<ShopProducts> {
  @override
  Widget build(BuildContext context) {
    void onDelete() {
      setState(() {});
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder(
              future: ProductController().getShopProducts(page: 1, limit: 20),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.black,
                  ));
                }
                List products = snapshot.requireData;
                // ignore: avoid_print
                print("Products");
                print(products);
                return products.isEmpty
                    ? noData()
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return products[index]['ProductImages'].length > 0
                              ? ShopProductCard(
                                  data: products[index], onDelete: onDelete)
                              : Container();
                        },
                      );
              }),
        ));
  }
}
