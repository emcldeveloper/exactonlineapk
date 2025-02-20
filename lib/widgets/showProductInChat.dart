import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_online/pages/viewImage.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showProductInChat(message) {
  RxInt index = 0.obs;
  Get.bottomSheet(Container(
    color: Colors.white,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300,
            color: Colors.grey[100],
            width: double.infinity,
            child: CarouselSlider(
              items: List.from(message.product.value["ProductImages"])
                  .map((item) => GestureDetector(
                        onTap: () {
                          Get.to(() => ViewImage(
                                index: index.value,
                                images: List.from(
                                        message.product.value["ProductImages"])
                                    .map((item) => item["image"] as String)
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                spacer(),
                Obx(
                  () => Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                            List.from(message.product.value["ProductImages"])
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
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ParagraphText(
                            message.product.value['name'] ?? '',
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                          ParagraphText(
                              "TZS ${toMoneyFormmat(message.product.value['sellingPrice'])}",
                              fontSize: 16.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
          )
        ],
      ),
    ),
  ));
}
