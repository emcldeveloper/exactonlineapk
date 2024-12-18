import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/seller_profile_page.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

final List<Map<String, dynamic>> profiles = [
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar1.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar2.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar3.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar4.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar5.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar6.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar7.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar8.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar9.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar10.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar11.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar12.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar13.png',
  },
  {
    'name': 'Vunja Bei Store',
    'followers': '200 followers',
    'imageUrl': 'assets/images/avatar14.png',
  },
];

Widget ReelsFollowingTab() {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.80,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellerProfilePage(
                    name: profiles[index]['name'],
                    followers: profiles[index]['followers'],
                    imageUrl: profiles[index]['imageUrl'],
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: Image.asset(
                      profiles[index]['imageUrl'],
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                spacer(),
                ParagraphText(profiles[index]['name'],
                    textAlign: TextAlign.center, fontSize: 14.0),
                spacer(),
                ParagraphText(profiles[index]['followers'],
                    color: mutedTextColor,
                    textAlign: TextAlign.center,
                    fontSize: 12.0),
              ],
            ),
          );
        },
      ),
    ),
  );
}
