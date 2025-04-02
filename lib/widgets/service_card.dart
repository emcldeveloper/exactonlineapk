// ignore_for_file: library_private_types_in_public_api

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/favorite_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/service_page.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class ServiceCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final double? height;
  final bool? isStagger;
  const ServiceCard(
      {required this.data, this.isStagger = false, this.height, super.key});

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  final UserController userController = Get.find();
  final FavoriteController favoriteController = Get.put(FavoriteController());

  RxBool isFavorite = false.obs;

  @override
  void initState() {
    super.initState();
    isFavorite.value = widget.data.containsKey('Favorites') &&
        widget.data['Favorites'] != null &&
        widget.data['Favorites'].isNotEmpty;
  }

  void _toggleFavorite() async {
    var userId = userController.user.value['id'] ?? "";

    if (isFavorite.value) {
      var favoriteId = widget.data['Favorites']?[0]['id'];
      if (favoriteId != null) {
        print("Deleting favorite with ID: $favoriteId");
        await favoriteController.deleteFavorite(favoriteId);
        isFavorite.value = false;
      }
    } else {
      var payload = {
        "ServiceId": widget.data['id'],
        "UserId": userId,
      };
      print("Adding to favorites: $payload");
      await favoriteController.addFavorite(payload);
      isFavorite.value = true;
    }
    favoriteController.fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicePage(serviceData: widget.data),
          ),
        );
      },
      child: SizedBox(
        width: 135,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  color: Colors.grey[200],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.data["ServiceImages"][0]['image'],
                      height: widget.height ??
                          (widget.isStagger == true ? null : 145),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Favorite Icon (Reactive)
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.data['type'] == "ad")
                        Container(
                          width: 40,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: ParagraphText("Ad", fontSize: 12),
                        ),
                      if (widget.data['type'] == "ad") const SizedBox(width: 8),
                      Expanded(
                        child: ParagraphText(
                          widget.data['name'],
                          fontSize: 13,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  ParagraphText(
                    "TZS ${toMoneyFormmat(widget.data['price'])}",
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    fontSize: 15.0,
                  ),
                  if (widget.data['shipping'] == "Free Shipping")
                    ParagraphText(
                      widget.data['shipping'],
                      fontSize: 12,
                      maxLines: 1,
                      color: Colors.red,
                    ),
                  ParagraphText(
                    widget.data["Shop"]?["name"] ?? "",
                    fontSize: 12,
                    maxLines: 1,
                    color: primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
