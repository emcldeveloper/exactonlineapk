import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/chat_page.dart';
import 'package:e_online/pages/favourites_page.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/pages/profile_page.dart';
import 'package:e_online/pages/reels_page.dart';
import 'package:flutter/material.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: mainColor,
        selectedItemColor: secondaryColor,
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
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  "assets/icons/home-2.png",
                  width: 22.0,
                ),
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Image.asset(
                "assets/icons/home-1.png",
                width: 22.0,
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  "assets/icons/trend-up-1.png",
                  width: 22.0,
                ),
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Image.asset(
                "assets/icons/trend-up-2.png",
                width: 22.0,
              ),
            ),
            label: "Reels",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  "assets/icons/message-1.png",
                  width: 22.0,
                ),
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Image.asset(
                "assets/icons/message-2.png",
                width: 22.0,
              ),
            ),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  "assets/icons/heart.png",
                  width: 22.0,
                ),
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Image.asset(
                "assets/icons/favorite.png",
                width: 22.0,
              ),
            ),
            label: "Favourites",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  "assets/icons/person-1.png",
                  width: 22.0,
                ),
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              child: Image.asset(
                "assets/icons/person-2.png",
                width: 22.0,
              ),
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
