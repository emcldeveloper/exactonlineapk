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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tilesItems = [
      {
        'points': "248",
        'title': "impressions",
      },
      {
        'points': "88",
        'title': "clicks",
      },
      {
        'points': "49",
        'title': "Shares",
      },
      {
        'points': "23",
        'title': "Calls",
      },
      {
        'points': "982",
        'title': "Likes",
      },
      {
        'points': "20",
        'title': "Profile views",
      },
    ];
    final List<Map<String, dynamic>> productItems = [
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
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
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
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: tilesItems.map((item) {
                    return Column(
                      children: [
                        ParagraphText(item['points'],
                            fontWeight: FontWeight.bold),
                        ParagraphText(item['title']),
                      ],
                    );
                  }).toList(),
                ),
                spacer1(),
                customButton(
                    onTap: () {
                      Get.to(() => AddProductPage());
                    },
                    text: "Add new Product",
                    vertical: 8.0),
                spacer1(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HeadingText("My Products (4)"),
                    Icon(Icons.menu_open_sharp),
                  ],
                ),
                spacer(),
                Column(
                  children: productItems.map((item) {
                    return HorizontalProductCard(data: item);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
