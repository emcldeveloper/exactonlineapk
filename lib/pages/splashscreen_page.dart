import 'package:e_online/widgets/heading_text.dart';
import 'package:flutter/material.dart';

class SplashscreenPage extends StatelessWidget {
  const SplashscreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: HeadingText("ExactOnline",
            textAlign: TextAlign.center, fontSize: 30.0),
      ),
    );
  }
}
