import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/auth/login_page.dart';
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
      HomePage(),
      ReelsPage(),
      ChatPage(),
      FavouritesPage(),
      ProfilePage(),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: mainColor,
        selectedItemColor: secondaryColor,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        currentIndex: activeTab,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            activeTab = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(AntDesign.home_outline),
            activeIcon: Icon(AntDesign.home_fill),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            activeIcon: Icon(Icons.trending_up_outlined),
            label: "Reels",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat_rounded),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(AntDesign.heart_outline),
            activeIcon: Icon(AntDesign.heart_fill),
            label: "Favourites",
          ),
          BottomNavigationBarItem(
            icon: Icon(AntDesign.user_outline),
            activeIcon: Icon(AntDesign.user_switch_outline),
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
