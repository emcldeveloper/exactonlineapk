import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/banner_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdsCarousel extends StatefulWidget {
  const AdsCarousel({super.key});

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  Rx<int> currentPage = Rx<int>(0);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: BannersController().getBanners(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          List<dynamic> banners =
              snapshot.requireData.map((item) => item["image"]).toList();
          return Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  height: 160,
                  viewportFraction: 1,
                  onPageChanged: (value, _) {
                    currentPage.value = value;
                  },
                ),
                items: banners.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: i,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      List.generate(banners.length, (int number) => number++)
                          .map((i) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Obx(
                          () => Container(
                            height: 7,
                            width: i == currentPage.value ? 15 : 7,
                            color: i == currentPage.value
                                ? secondaryColor
                                : const Color(0xffEBEBEB),
                          ),
                        ),
                      ),
                    );
                  }).toList())
            ],
          );
        });
  }
}
