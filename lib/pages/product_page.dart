import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/product_item.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

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
        appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              color: Colors.transparent,
              child: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: secondaryColor,
              ),
            )),
        title: ParagraphText("Join as seller"),
        centerTitle: true,
        actions: [
          Icon(Icons.share),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customButton(
              onTap: () {
                Get.to(() => HomePage());
              },
              text: "Contact Seller",
            ),
            spacer(),
            ParagraphText("View more seller products"),
            spacer(),
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
            ParagraphText("Lorem ipsum dolor sit amet consectetur. Congue gravida ullamcorper ac diam eget facilisis tincidunt. Cursus massa etiam tempor magnis."),
           Row(
            children: [
              Expanded(child: HeadingText("Related Products")),
              ParagraphText("See All"),
            ],
          ),
          spacer(),
          customButton(
              onTap: () {
                Get.to(() => HomePage());
              },
              text: "Contact Seller"),
          spacer(),
          ParagraphText("View more seller products"),
          spacer(),
          ],
        ),
      ),
    );
  }
}

