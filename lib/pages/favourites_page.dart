import 'package:e_online/widgets/heading_text.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeadingText("FAVOURITE PAGE"),
        ],
      ),
    );
  }
}