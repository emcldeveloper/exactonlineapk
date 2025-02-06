import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/chat_page.dart';
import 'package:e_online/pages/favourites_page.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/pages/profile_page.dart';
import 'package:e_online/pages/reels_page.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int activeTab = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const HomePage(),
      const ReelsPage(),
      ChatPage(),
      const FavouritesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: mainColor,
        selectedItemColor: Colors.black,
        unselectedItemColor: mutedTextColor,
        showSelectedLabels: true,
        currentIndex: activeTab,
        showUnselectedLabels: true,
        unselectedLabelStyle: TextStyle(
            fontSize: 11, color: const Color.fromARGB(255, 194, 192, 192)),
        selectedLabelStyle: TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            activeTab = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.home),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.home_filled),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(EvaIcons.video_outline),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(EvaIcons.video),
            ),
            label: "Reels",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.chat_bubble),
            ),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.favorite_outline),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.favorite),
            ),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.person_2_outlined),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.person_2),
            ),
            label: "Profile",
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 1.0,
            color: Colors.grey,
          ),
          Expanded(
            child: pages[activeTab],
          ),
        ],
      ),
    );
  }
}
