import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/reel_controller.dart';
import 'package:e_online/pages/preview_reel_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class HomeReels extends StatelessWidget {
  const HomeReels({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ReelController().getReels(page: 1, limit: 10),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          var res = snapshot.requireData;
          final newReels = (res as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList();
          return Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: newReels
                  .map((item) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreviewReelPage(reel: item),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            children: [
                              ClipOval(
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border:
                                          Border.all(color: primary, width: 2)),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: item["thumbnail"],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              ParagraphText(item["Shop"]["name"],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.grey[700])
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
        });
  }
}
