import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/pages/reels_page.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/seller_shop_products.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class SellerProfilePage extends StatelessWidget {
  final String name;
  final String followers;
  final String imageUrl;

  const SellerProfilePage({
    super.key,
    required this.name,
    required this.followers,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          backgroundColor: mainColor,
          leading: InkWell(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios,
              color: mutedTextColor,
              size: 16.0,
            ),
          ),
          title: HeadingText("Shop Details"),
          centerTitle: true,
          actions: [
            InkWell(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                color: Colors.black,
                size: 24.0,
              ),
              onTap: () {},
            ),
            const SizedBox(
              width: 8,
            ),
            InkWell(
              child: const Icon(Icons.local_phone_outlined,
                  color: Colors.black, size: 24),
              onTap: () {},
            ),
            const SizedBox(
              width: 8,
            ),
            InkWell(
              onTap: () {},
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedMessage01,
                color: Colors.black,
                size: 24.0,
              ),
            ),
            const SizedBox(
              width: 16,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: primaryColor,
              height: 1.0,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: Image.asset(
                        imageUrl,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HeadingText(name),
                                ParagraphText("Sinza, Dar es salaam, Tanzania"),
                              ],
                            ),
                            Container(
                              width: 70,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.center,
                              child: ParagraphText(
                                "Open",
                                color: Colors.green[800],
                              ),
                            ),
                          ],
                        ),
                        spacer(),
                        ParagraphText("Description",
                            fontWeight: FontWeight.bold),
                        ParagraphText(
                            "Lorem feugiat amet semper varius  ipsum. Parturient aenrutrum tortor sempe...."),
                      ],
                    ),
                  )
                ],
              ),
            ),
            spacer1(),
            TabBar(
              isScrollable: true,
              labelColor: Colors.black,
              dividerColor: const Color.fromARGB(255, 234, 234, 234),
              unselectedLabelColor: mutedTextColor,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2,
                  color: Colors.black,
                ),
              ),
              tabs: const [
                Tab(text: "Shop Products"),
                Tab(text: "Reels"),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TabBarView(
                  children: [
                    // Shop Products Tab
                    sellerShopProducts(),
                    // Reels Tab
                    ProductMasonryGrid(productItems: productItems),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
