import 'package:e_online/widgets/heading_text.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

Widget noData() {
  return Center(
    child: Builder(builder: (context) {
      return Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                height: 200,
                child: Image.asset("assets/icons/searchicon.avif")),
            HeadingText("No Data Available"),
            Text(
              "Once data is available, it will be displayed here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }),
  );
}
