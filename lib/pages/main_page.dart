import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/pages/chat_page.dart';
import 'package:e_online/pages/favourites_page.dart';
import 'package:e_online/pages/home_page.dart';
import 'package:e_online/pages/my_orders_page.dart';
import 'package:e_online/pages/profile_page.dart';
import 'package:e_online/pages/reels_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int activeTab = 0;
  UserController userController = Get.find();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  @override
  Widget build(BuildContext context) {
    _firebaseMessaging.getToken().then((value) {
      userController
          .updateUserData(userController.user.value["id"], {"token": value});
    });
    List<Widget> pages = [
      const HomePage(),
      const ReelsPage(),
      ChatPage(),
      MyOrdersPage(),
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
        unselectedLabelStyle: GoogleFonts.geologica(
            fontSize: 11, color: Color.fromARGB(255, 194, 192, 192)),
        selectedLabelStyle: GoogleFonts.geologica(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            activeTab = value;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.home),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.home_filled),
            ),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(EvaIcons.video_outline),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(EvaIcons.video),
            ),
            label: "Reels",
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.chat_bubble),
            ),
            label: "Chats",
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Bootstrap.bag),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Bootstrap.bag_fill),
            ),
            label: "My Orders",
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6, top: 6),
              child: Icon(Icons.person_2_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 6, top: 6),
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
