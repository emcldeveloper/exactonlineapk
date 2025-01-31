import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/favorite_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/cart_page.dart';
import 'package:e_online/pages/chat_page.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/report_seller.dart';
import 'package:e_online/widgets/reviews.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductPage({required this.productData, super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late String selectedImage = widget.productData["ProductImages"][0]["id"];
  late List<String> productImages;
  final UserController userController = Get.find();
  final FavoriteController favoriteController = Get.put(FavoriteController());

  @override
  void initState() {
    super.initState();
    favoriteController.fetchFavorites();
    getData();
  }

  void getData() {}

  void _updateSelectedImage(String image) {
    setState(() {
      selectedImage = image;
    });
  }

  bool get isFavorite {
    return favoriteController.favorites
        .any((item) => item['id'] == widget.productData['id']);
  }

  void _toggleFavorite() async {
    var userId = userController.user.value['id'] ?? "";
    if (isFavorite) {
      await favoriteController.deleteFavorite(widget.productData['id']);
    } else {
      var payload = {
        "ProductId": widget.productData['id'],
        "UserId": userId,
      };
      await favoriteController.addFavorite(payload);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isFavorite ? "Removed from Favorites" : "Added to Favorites"),
      ),
    );
  }

  void _showReviewsBottomSheet() {
    final List<Map<String, dynamic>> sampleReviews = [
      {
        'name': 'John Doe',
        'comment': 'Great product!',
        'rating': 5,
      },
      {
        'name': 'John Chuma',
        'comment':
            'I used bough this product it is very nice , i would recommend you guys to buy this',
        'rating': 3,
      },
      {
        'name': 'John Doe',
        'comment': 'Great product!',
        'rating': 4.5,
      },
      {
        'name': 'John Coe',
        'comment': 'Great product!',
        'rating': 2,
      },
      {
        'name': 'John Doe',
        'comment':
            'I used bough this product it is very nice , i would recommend you guys to buy this',
        'rating': 5,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReviewBottomSheet(
          rating: 4.5,
          reviews: sampleReviews,
        ),
      ),
    );
  }

  void _showReportSellerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const ReportSellerBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          backgroundColor: mainColor,
          leading: InkWell(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios,
              color: secondaryColor,
              size: 16.0,
            ),
          ),
          title: HeadingText("Product Details"),
          centerTitle: true,
          actions: [
            InkWell(
              onTap: () {
                Get.to(CartPage());
              },
              child: const Icon(
                Bootstrap.bag,
                color: Colors.black,
                size: 20.0,
              ),
            ),
            SizedBox(
              width: 8.0,
            ),
            InkWell(
              onTap: () {},
              child: Icon(
                Bootstrap.share,
                color: Colors.black,
                size: 20.0,
              ),
            ),
            SizedBox(
              width: 8.0,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color.fromARGB(255, 242, 242, 242),
              height: 1.0,
            ),
          ),
        ),
        body: FutureBuilder(
            future:ProductController().getProduct(id: widget.productData["id"]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.black,
                ));
              }
              var product = snapshot.requireData;
              print(product);
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: List.from(product["ProductImages"])
                                  .firstWhere((element) =>
                                      element["id"] == selectedImage)?["image"],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Favorite icon container always on top of the image
                          Container(),
                          Positioned(
                            top: 15,
                            right: 15,
                            child: GestureDetector(
                              onTap: _toggleFavorite,
                              child: ClipOval(
                                child: Container(
                                  color: Colors.white.withOpacity(0.8),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    isFavorite
                                        ? AntDesign.heart_fill
                                        : AntDesign.heart_outline,
                                    color:
                                        isFavorite ? Colors.red : Colors.black,
                                    size: 22.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      spacer(),
                      if (widget.productData["ProductImages"].isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: widget.productData["ProductImages"]
                                .map<Widget>((image) {
                              final isSelected = image["id"] == selectedImage;
                              return GestureDetector(
                                onTap: () {
                                  _updateSelectedImage(image["id"]);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.black, width: 2)
                                        : null,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        imageUrl: image["image"],
                                        height: 50,
                                        width: 50,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ParagraphText(
                                  product['name'] ?? '',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.0,
                                ),
                                ParagraphText(
                                    "TZS ${toMoneyFormmat(product['sellingPrice'])}",
                                    fontSize: 16.0),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 16.0,
                                  ),
                                  const SizedBox(width: 2),
                                  ParagraphText(
                                    (product['rating'] ?? 0).toString(),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _showReviewsBottomSheet,
                                child: ParagraphText(
                                  "View reviews",
                                  color: mutedTextColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      spacer(),
                      ParagraphText(
                        product['description'],
                      ),
                      spacer1(),
                      ParagraphText(
                        "Specifications",
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.productData['specifications'].entries
                            .map<Widget>((entry) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ParagraphText(
                                "${entry.key}:", // Display the key
                                color: mutedTextColor,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              ParagraphText(
                                "${entry.value}", // Display the corresponding value
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          );
                        }).toList(),
                      ),

                      spacer1(),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     HeadingText("Recomended"),
                      //     ParagraphText(
                      //       "See All",
                      //       color: mutedTextColor,
                      //       decoration: TextDecoration.underline,
                      //     ),
                      //   ],
                      // ),
                      // spacer1(),
                      // SizedBox(
                      //   height: 240,
                      //   child: ListView.builder(
                      //     scrollDirection: Axis.horizontal,
                      //     itemCount: relatedItems.length,
                      //     itemBuilder: (context, index) {
                      //       return Padding(
                      //         padding: const EdgeInsets.only(right: 16.0),
                      //         child: ProductCard(data: relatedItems[index]),
                      //       );
                      //     },
                      //   ),
                      // ),
                      spacer1(),
                      customButton(
                        onTap: () => Get.to(() => const CartPage()),
                        text: "Add to Cart",
                      ),
                      spacer(),
                      customButton(
                        onTap: () async {
                          await launchUrl(Uri(
                              scheme: "tel", path: product["Shop"]["phone"]));
                        },
                        text: "Call Seller",
                        buttonColor: primaryColor,
                        textColor: Colors.black,
                      ),
                      spacer(),
                      customButton(
                        onTap: () => Get.to(() => ChatPage()),
                        text: "Message Seller",
                        buttonColor: primaryColor,
                        textColor: Colors.black,
                      ),
                      spacer(),
                      customButton(
                        onTap: () {
                          _showReportSellerBottomSheet();
                        },
                        text: "Report seller",
                        buttonColor: Colors.transparent,
                        textColor: Colors.red,
                      ),
                      spacer2(),
                    ],
                  ),
                ),
              );
            }));
  }
}
