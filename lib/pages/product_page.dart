import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/chat_controller.dart';
import 'package:e_online/controllers/favorite_controller.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/controllers/ordered_products_controller.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/review_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/cart_page.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/utils/snackbars.dart';
import 'package:e_online/widgets/cartIcon.dart';
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
  Map<String, dynamic> productData;

  ProductPage({required this.productData, super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late String selectedImage = widget.productData["ProductImages"][0]["id"];
  late List<String> productImages;
  final UserController userController = Get.find();
  final ProductController productController = Get.put(ProductController());
  final FavoriteController favoriteController = Get.put(FavoriteController());
  final ReviewController reviewController = Get.put(ReviewController());
  late List<Map<String, dynamic>> reviews = [];
  // String userId = "";

  @override
  void initState() {
    super.initState();
    isFavorite.value = widget.productData.containsKey('Favorites') &&
        widget.productData['Favorites'] != null &&
        widget.productData['Favorites'].isNotEmpty;
    getData();
    _callProductReviews();
    _sendProductStats("view");
  }

  void getData() {}

  void _updateSelectedImage(String image) {
    setState(() {
      selectedImage = image;
    });
  }

  RxBool isFavorite = false.obs;

  void _toggleFavorite(Map<String, dynamic> product) async {
    var userId = userController.user.value['id'] ?? "";

    if (isFavorite.value) {
      var favoriteId = product['Favorites']?[0]['id'];
      if (favoriteId != null) {
        print("Deleting favorite with ID: $favoriteId");
        await favoriteController.deleteFavorite(favoriteId);
        isFavorite.value = false;
      }
    } else {
      var payload = {
        "ProductId": product['id'],
        "UserId": userId,
      };
      print("Adding to favorites: $payload");
      await favoriteController.addFavorite(payload);
      isFavorite.value = true;
    }
    favoriteController.fetchFavorites();
  }

  Future<void> _sendProductStats(String type) async {
    var userId = userController.user.value['id'] ?? "";
    try {
      var payload = {
        "ProductId": widget.productData['id'],
        "UserId": userId,
        "type": type
      };

      await productController.addProductStats(payload);
    } catch (e) {
      debugPrint("Error sending shop stats: $e");
    }
  }

  List<Map<String, dynamic>> _callProductReviews() {
    List<Map<String, dynamic>> fetchedReviews =
        (widget.productData['ProductReviews'] as List<dynamic>)
            .map((review) => {
                  "name": review["User"]?["name"] ?? "NA",
                  "rating": review["rating"] ?? 0,
                  "description": review["description"] ?? "No description",
                })
            .toList();

    return fetchedReviews;
  }

  double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 0.0;

    double totalRating = reviews.fold(
        0.0, (sum, review) => sum + (review['rating'] as num).toDouble());
    return totalRating / reviews.length;
  }

  void _showReviewsBottomSheet() async {
    reviews = _callProductReviews();
    print(reviews);
    var productId = widget.productData['id'];
    print("full data before taking the review part");
    print(widget.productData);
    print("reviews");
    print(reviews);

    double averageRating = calculateAverageRating(reviews);
    // print("averageRating");
    // print(averageRating);
    await showModalBottomSheet(
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
          rating: averageRating,
          productId: productId,
          reviews: reviews,
        ),
      ),
    );
    setState(() {});
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

  var addingToCart = false.obs;
  OrderedProductController orderedProductController = Get.find();

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
            cartIcon(),
            SizedBox(
              width: 8.0,
            ),
            InkWell(
              onTap: () {
                _sendProductStats("share");
              },
              child: Icon(
                Bootstrap.share,
                color: Colors.black,
                size: 20.0,
              ),
            ),
            SizedBox(
              width: 12.0,
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
            future:
                ProductController().getProduct(id: widget.productData["id"]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.black,
                ));
              }
              var product = snapshot.requireData;
              widget.productData = product;
              // Set isFavorite based on fetched product
              isFavorite.value = product.containsKey('Favorites') &&
                  product['Favorites'] != null &&
                  product['Favorites'].isNotEmpty;

              print(product);
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 300,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(0),
                              child: CachedNetworkImage(
                                imageUrl: List.from(product["ProductImages"])
                                    .firstWhere((element) =>
                                        element["id"] ==
                                        selectedImage)?["image"],
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Favorite icon container always on top of the image
                          Container(),
                          Positioned(
                            top: 15,
                            right: 15,
                            child: GestureDetector(
                              onTap: () => _toggleFavorite(product),
                              child: ClipOval(
                                child: Obx(() => Container(
                                      color: Colors.white60,
                                      padding: const EdgeInsets.all(6.0),
                                      child: Icon(
                                        isFavorite.value
                                            ? AntDesign.heart_fill
                                            : AntDesign.heart_outline,
                                        color: isFavorite.value
                                            ? Colors.red
                                            : Colors.black,
                                        size: 18.0,
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            spacer(),
                            if (widget.productData["ProductImages"].isNotEmpty)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: widget.productData["ProductImages"]
                                      .map<Widget>((image) {
                                    final isSelected =
                                        image["id"] == selectedImage;
                                    return GestureDetector(
                                      onTap: () {
                                        _updateSelectedImage(image["id"]);
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(right: 8.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          border: isSelected
                                              ? Border.all(
                                                  color: Colors.black, width: 2)
                                              : null,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              children: widget
                                  .productData['specifications'].entries
                                  .map<Widget>((entry) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                            if (product["OrderedProducts"].length < 1)
                              Obx(
                                () => customButton(
                                  loading: addingToCart.value,
                                  onTap: () {
                                    addingToCart.value = true;
                                    OrdersController().addOrder({}).then((res) {
                                      orderedProductController
                                          .addOrderedProduct({
                                        "OrderId": res["id"],
                                        "ProductId": product["id"]
                                      }).then((res) {
                                        showSuccessSnackbar(
                                            title: "Added successfully",
                                            description:
                                                "Product is added to cart successfully");
                                        addingToCart.value = false;

                                        setState(() {});
                                        orderedProductController
                                            .getOnCartproducts();
                                      });
                                    });
                                  },
                                  text: "Add to Cart",
                                ),
                              ),
                            if (product["OrderedProducts"].length > 0)
                              customButton(
                                loading: addingToCart.value,
                                onTap: () {
                                  Get.to(() => CartPage());
                                },
                                text: "View in Cart",
                              ),

                            spacer(),
                            customButton(
                              onTap: () async {
                                _sendProductStats("call");
                                await launchUrl(Uri(
                                    scheme: "tel",
                                    path: product["Shop"]["phone"]));
                              },
                              text: "Call Seller",
                              buttonColor: primaryColor,
                              textColor: Colors.black,
                            ),
                            spacer(),
                            customButton(
                              onTap: () {
                                _sendProductStats("message");
                                ChatController().addChat({
                                  "ShopId": product["Shop"]["id"],
                                  "UserId": userController.user.value["id"]
                                }).then((res) {
                                  print(res);

                                  Get.to(() => ConversationPage(res[0]));
                                });
                              },
                              text: "Message Seller",
                              buttonColor: primaryColor,
                              textColor: Colors.black,
                            ),
                            spacer(),

                            spacer2(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }));
  }
}
