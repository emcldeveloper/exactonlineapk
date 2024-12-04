import 'package:flutter/material.dart';

class SplashscreenPage extends StatelessWidget {
  const SplashscreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          height: 55,
          width: double.infinity,
          child: Image.asset("assets/images/EonlineLogo.png"),
        ),
      ),
    );
  }
}
