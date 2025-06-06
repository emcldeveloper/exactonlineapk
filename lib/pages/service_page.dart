import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/chat_controller.dart';
import 'package:e_online/controllers/favorite_controller.dart';
import 'package:e_online/controllers/following_controller.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/controllers/service_controller.dart';
import 'package:e_online/controllers/review_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/cart_page.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/pages/home_page_sections/all_services.dart';
import 'package:e_online/pages/my_shop_page.dart';
import 'package:e_online/pages/seller_profile_page.dart';
import 'package:e_online/pages/viewImage.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/utils/get_hex_color.dart';
import 'package:e_online/utils/snackbars.dart';
import 'package:e_online/widgets/cartIcon.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/related_services.dart';
import 'package:e_online/widgets/report_seller.dart';
import 'package:e_online/widgets/reviews.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ServicePage extends StatefulWidget {
  Map<String, dynamic> serviceData;

  ServicePage({required this.serviceData, super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late String selectedImage = widget.serviceData["ServiceImages"][0]["id"];
  late List<String> serviceImages;
  final UserController userController = Get.find();
  final ServiceController serviceController = Get.put(ServiceController());
  final FavoriteController favoriteController = Get.put(FavoriteController());
  final ReviewController reviewController = Get.put(ReviewController());
  late List<Map<String, dynamic>> reviews = [];
  RxBool isSharing = false.obs;
  // String userId = "";

  @override
  void initState() {
    super.initState();
    isFavorite.value = widget.serviceData.containsKey('Favorites') &&
        widget.serviceData['Favorites'] != null &&
        widget.serviceData['Favorites'].isNotEmpty;
    getData();
    _sendServiceStats("view");
  }

  void getData() {}

  void _updateSelectedImage(String image) {
    setState(() {
      selectedImage = image;
    });
  }

  RxBool isFavorite = false.obs;

  void _toggleFavorite(Map<String, dynamic> service) async {
    var userId = userController.user.value['id'] ?? "";

    if (isFavorite.value) {
      var favoriteId = service['Favorites']?[0]['id'];
      if (favoriteId != null) {
        await favoriteController.deleteFavorite(favoriteId);
        isFavorite.value = false;
      }
    } else {
      var payload = {
        "ServiceId": service['id'],
        "UserId": userId,
      };
      await favoriteController.addFavorite(payload);
      isFavorite.value = true;
    }
    favoriteController.fetchFavorites();
  }

  Future<void> _sendServiceStats(String type) async {
    var userId = userController.user.value['id'] ?? "";
    try {
      var payload = {
        "ServiceId": widget.serviceData['id'],
        "UserId": userId,
        "type": type
      };

      await serviceController.addServiceStats(payload);
    } catch (e) {
      debugPrint("Error sending shop stats: $e");
    }
  }

  void _shareService() async {
    isSharing.value = true;

    await _sendServiceStats("share");

    const String appLink = "https://api.exactonline.co.tz/open-app/";
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.exactonline.exactonline";
    const String appStoreLink = "https://apps.apple.com/app/idYOUR_APP_ID";

    String serviceId = widget.serviceData['id'];
    String serviceName =
        widget.serviceData['name'] ?? 'Check out this service!';
    String price = widget.serviceData['sellingPrice'] != null
        ? " TZS ${toMoneyFormmat(widget.serviceData['sellingPrice'])}"
        : '';

    String shareText = "$serviceName for a price of $price";

    String fullAppLink = "$appLink?serviceId=$serviceId";

    // Fetch image URL
    String imageUrl = widget.serviceData["ServiceImages"][0]["image"];

    try {
      // Download image to temporary directory
      final response = await http.get(Uri.parse(imageUrl));
      final documentDirectory = await getTemporaryDirectory();
      final file = File('${documentDirectory.path}/service.jpg');
      await file.writeAsBytes(response.bodyBytes);

      // Share image with text
      await Share.shareXFiles([XFile(file.path)],
          text:
              "$shareText\n\nCheck out this service or explore more on ExactOnline! $fullAppLink");
    } catch (e) {
      print("Error sharing service image: $e");
      // If image fails, share text only
      await Share.share(
          "$shareText\n\nCheck out this service or explore more on ExactOnline! $fullAppLink");
    }
    isSharing.value = false;
  }

  double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 0.0;

    double totalRating = reviews.fold(
        0.0, (sum, review) => sum + (review['rating'] as num).toDouble());
    return totalRating / reviews.length;
  }

  void _showReviewsBottomSheet() async {
    var serviceId = widget.serviceData['id'];

    double averageRating = calculateAverageRating(reviews);

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
  RxInt index = 0.obs;
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
        title: HeadingText("Service Details"),
        centerTitle: true,
        actions: [
          SizedBox(
            width: 12.0,
          ),
        ],
      ),
      body: FutureBuilder(
          future: ServiceController().getService(id: widget.serviceData["id"]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.black,
              ));
            }
            var service = snapshot.requireData;
            widget.serviceData = service;
            // Set isFavorite based on fetched service
            isFavorite.value = service.containsKey('Favorites') &&
                service['Favorites'] != null &&
                service['Favorites'].isNotEmpty;

            return Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => SellerProfilePage(
                                    shopId: service["Shop"]["id"]));
                              },
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            service["Shop"]['shopImage'] ?? "",
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          decoration:
                                              BoxDecoration(color: primary),
                                          alignment: Alignment.center,
                                          child: Center(
                                            child: Text(
                                              service["Shop"]["name"]
                                                  .toString()[0],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        HeadingText(
                                            "From ${service["Shop"]["name"]}",
                                            fontSize: 16.0),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.pin_drop,
                                              color: Colors.green,
                                              size: 18,
                                            ),
                                            ParagraphText(
                                                "${service["Shop"]["address"]}",
                                                color: Colors.grey,
                                                fontSize: 13.0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (service["Shop"]["following"] == false)
                                    GestureDetector(
                                      onTap: () {
                                        var payload = {
                                          "ShopId": service["Shop"]["id"],
                                          "UserId":
                                              userController.user.value["id"]
                                        };
                                        // print(payload);
                                        FollowingController()
                                            .followShop(payload)
                                            .then((res) => {setState(() {})});
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Container(
                                          color: primary,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            child: ParagraphText("Follow",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (service["Shop"]["following"] == true)
                                    GestureDetector(
                                      onTap: () {
                                        var payload = {
                                          "ShopId": service["Shop"]["id"],
                                          "UserId":
                                              userController.user.value["id"]
                                        };
                                        // print(payload);
                                        FollowingController()
                                            .deleteFollowing(service["Shop"]
                                                ["ShopFollowers"][0]["id"])
                                            .then((res) => {setState(() {})});
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Container(
                                          color: primary.withAlpha(20),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            child: ParagraphText("Following",
                                                fontWeight: FontWeight.bold,
                                                color: primary,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(00),
                                child: Container(
                                  height: 300,
                                  color: Colors.black,
                                  width: double.infinity,
                                  child: CarouselSlider(
                                    items: List.from(service["ServiceImages"])
                                        .map((item) => GestureDetector(
                                              onTap: () {
                                                Get.to(() => ViewImage(
                                                      index: index.value,
                                                      images: List.from(service[
                                                              "ServiceImages"])
                                                          .map((item) =>
                                                              item["image"]
                                                                  as String)
                                                          .toList(),
                                                    ));
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                child: CachedNetworkImage(
                                                  imageUrl: item["image"],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    options: CarouselOptions(
                                        onPageChanged: (current, reason) {
                                          index.value = current;
                                        },
                                        autoPlay: true,
                                        aspectRatio: 1,
                                        viewportFraction: 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Obx(
                            () => Row(
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                      List.from(service["ServiceImages"])
                                          .length,
                                      (index) => (index - 1) + 1,
                                      growable: true)
                                  .map((item) => ClipOval(
                                          child: Container(
                                        width: 10,
                                        color: index.value == item
                                            ? Colors.orange
                                            : Colors.grey[300],
                                        height: 10,
                                      )))
                                  .toList(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ParagraphText(
                                            service['name'] ?? '',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                          ),
                                          ParagraphText(
                                              "TZS ${toMoneyFormmat(service['price'])}",
                                              color: primary,
                                              fontSize: 16.0),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                spacer(),
                                ParagraphText(
                                  service['description'],
                                ),
                                spacer1(),
                                HeadingText("Related Services", fontSize: 18),
                                RelatedServices(
                                  serviceId: widget.serviceData["id"],
                                ),
                                spacer1(),
                                spacer2(),
                                spacer2(),
                                spacer2(),
                                spacer2(),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 50, top: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: customButton(
                                      textColor: Colors.black87,
                                      buttonColor: Colors.grey[200],
                                      onTap: () async {
                                        await analytics.logEvent(
                                          name: 'chat_seller',
                                          parameters: {
                                            'Shop_Id': service["Shop"]["id"],
                                            'service_id': service["id"],
                                            'service_name': service['name'],
                                            'service_description':
                                                service['description'],
                                            'price': service['price'],
                                            'shopName': service["Shop"]["name"],
                                            'shopPhone': service["Shop"]
                                                ["phone"],
                                            'from_page': 'ServicePage'
                                          },
                                        );
                                        // _sendServiceStats("message");
                                        ChatController().addChat({
                                          "ShopId": service["Shop"]["id"],
                                          "ServiceId": service["id"],
                                          "UserId":
                                              userController.user.value["id"]
                                        }).then((res) {
                                          print(res);
                                          Get.to(() => ConversationPage(res));
                                        });
                                      },
                                      text: "Message"),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: customButton(
                                      onTap: () async {
                                        await launchUrl(Uri(
                                            scheme: "tel",
                                            path: service["Shop"]["phone"]));
                                      },
                                      text: "Call Us"),
                                ),
                              ],
                            ),
                          )))
                ],
              ),
            );
          }),
    );
  }
}
