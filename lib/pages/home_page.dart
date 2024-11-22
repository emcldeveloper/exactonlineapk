import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/product_item.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        title: HeadingText("E-Online"),
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 16),
          Icon(AntDesign.profile_outline),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTabController(
                length: 6,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.black,
                      tabs: [
                        Tab(text: "All"),
                        Tab(text: "Electronics"),
                        Tab(text: "Accessories"),
                        Tab(text: "Clothes"),
                        Tab(text: "Decorations"),
                        Tab(text: "Appliances"),
                      ],
                    ),
                    const SizedBox(
                      height: 300,
                      child: TabBarView(
                        children: [
                          Center(child: Text("All")),
                          Center(child: Text("Electronics")),
                          Center(child: Text("Accessories")),
                          Center(child: Text("Clothes")),
                          Center(child: Text("Decorations")),
                          Center(child: Text("Appliances")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              spacer1(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeadingText("New Arrival"),
                  ParagraphText("See All"),
                ],
              ),
              spacer1(),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ProductCard(data: productItems[index]),
                    );
                  },
                ),
              ),
              spacer1(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeadingText("For You"),
                  ParagraphText("See All"),
                ],
              ),
               spacer1(),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ProductCard(data: productItems[index]),
                    );
                  },
                ),
              ),
              // Column(
              //   children: productItems.map((item) => ProductCard(data: item)).toList(),
              // ),
              spacer2(),
            ],
          ),
        ),
      ),
    );
  }
}
