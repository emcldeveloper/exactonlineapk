import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewImage extends StatefulWidget {
  final int index;
  final List<String> images;

  ViewImage({required this.index, required this.images, super.key});

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  @override
  void initState() {
    super.initState();
    trackScreenView("ViewImage");
  }

  bool _isZoomed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Container(
            color: Colors.transparent,
            child: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
              size: 16.0,
            ),
          ),
        ),
      ),
      body: Center(
        child: CarouselSlider(
          items: widget.images
              .map((item) => GestureDetector(
                    onScaleStart: (_) => setState(() => _isZoomed = true),
                    onScaleEnd: (_) => setState(() => _isZoomed = false),
                    child: InteractiveViewer(
                      panEnabled: true, // Enable panning
                      boundaryMargin: EdgeInsets.all(20), // Allow movement
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: CachedNetworkImage(
                        imageUrl: item,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ))
              .toList(),
          options: CarouselOptions(
            initialPage: widget.index,
            aspectRatio: 0.58,
            viewportFraction: 1,
            enableInfiniteScroll:
                !_isZoomed, // Disable infinite scroll when zooming
            scrollPhysics: _isZoomed
                ? NeverScrollableScrollPhysics()
                : AlwaysScrollableScrollPhysics(), // Disable swipe when zooming
          ),
        ),
      ),
    );
  }
}
