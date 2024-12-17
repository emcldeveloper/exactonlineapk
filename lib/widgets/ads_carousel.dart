import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AdsCarousel extends StatefulWidget {
  const AdsCarousel({super.key});

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  int _currentPage = 0;
  final List<String> carouselImages = [
    "assets/ads/ad1.jpg",
    "assets/ads/ad2.jpg",
    "assets/ads/ad3.jpg",
    "assets/ads/ad4.jpg",
  ];
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        initialPage: 0,
        height: 160,
        viewportFraction: 1,
        onPageChanged: (value, _) {
          setState(() {
            _currentPage = value;
          });
        },
      ),
      items: carouselImages.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Image.asset(i, fit: BoxFit.contain);
          },
        );
      }).toList(),
    );
  }
}
