import 'package:e_online/widgets/heading_text.dart';
import 'package:flutter/material.dart';

class SplashscreenPage extends StatelessWidget {
  const SplashscreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HeadingText("Exact",
                textAlign: TextAlign.center,
                fontSize: 38.0,
                color: Color(0xffFF8000)),
            HeadingText("Online", textAlign: TextAlign.center, fontSize: 35.0)
          ],
        ),
      ),
    );
  }
}
