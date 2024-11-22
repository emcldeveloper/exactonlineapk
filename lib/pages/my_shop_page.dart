import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/product_item.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class MyShopPage extends StatelessWidget {
  const MyShopPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> productItems = [
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/teal_tshirt.png",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/red_tshirt.png",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/black_tshirt.png",
        'rating': 4.5,
      },
      {
        'title': "J.Crew T-shirt",
        'price': "25,000 TSH",
        'imageUrl': "assets/images/green_tshirt.png",
        'rating': 4.5,
      },
    ];
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        // leading: HeadingText("E-Online"),
        title:  HeadingText("E-Online"),
        actions: [  
          Icon(Icons.search),
          Icon(AntDesign.profile_outline),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
        Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeadingText("New Arrival"),
                  ParagraphText("See All"),
                ],
              ),
              spacer(),
              Column(
                children: productItems.map((item) {
                  return ProductCard(data: item); // Pass entire item map
                }).toList(),
              ),
              spacer2(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeadingText("For you"),
                  ParagraphText("See All"),
                ],
              ),
               spacer(),
              Column(
                children: productItems.map((item) {
                  return ProductCard(data: item); // Pass entire item map
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
