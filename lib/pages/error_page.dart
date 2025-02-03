import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 200, child: Image.asset("assets/images/nodata.png")),
            HeadingText("Oops! something went wrong"),
            ParagraphText("Couldn't load the page, due to some issues")
          ],
        ),
      ),
    );
  }
}
