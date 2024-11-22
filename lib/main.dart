import 'package:e_online/pages/splashscreen_page.dart';
import 'package:e_online/pages/way_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: "E-Online",
        theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
        home: FutureBuilder(
            future: Future.delayed(const Duration(seconds: 4)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashscreenPage();
              }
              return const WayPage();
            }));
  }
}