import 'package:e_online/constants/colors.dart';
import 'package:e_online/widgets/chat_card.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/search_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isSearching = false;

  final List<Map<String, dynamic>> chatItems = [
    {
      'avatar': "assets/images/avatar.png",
      'name': "James Jackson",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
    {
      'avatar': "assets/images/avatar1.png",
      'name': "Brian james",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
    {
      'avatar': "assets/images/avatar2.png",
      'name': "Japhet Alpha",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
    {
      'avatar': "assets/images/avatar3.png",
      'name': "Abdul Juma",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
    {
      'avatar': "assets/images/avatar4.png",
      'name': "Lameck Ayo",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
    {
      'avatar': "assets/images/avatar5.png",
      'name': "Dani Juma",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
    {
      'avatar': "assets/images/avatar6.png",
      'name': "Hamisi Hamisa",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
    {
      'avatar': "assets/images/avatar7.png",
      'name': "Neema Juma",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
    {
      'avatar': "assets/images/avatar8.png",
      'name': "Agness Mwene",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
    {
      'avatar': "assets/images/avatar9.png",
      'name': "Wamia Juma",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
    {
      'avatar': "assets/images/avatar10.png",
      'name': "Wazuri Group",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
    {
      'avatar': "assets/images/avatar11.png",
      'name': "coding Group",
      'message':
          "Nahitaji hili gauni lakini la rangi nyeusi, vipi naweza kulipata",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: _isSearching ? _buildSearchAppBar() : _buildDefaultAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: chatItems.map((chat) {
              return GestureDetector(
                onTap: () {
                  Get.toNamed('/conversation', arguments: chat);
                },
                child: chatCard(chat),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Default AppBar with search icon
  AppBar _buildDefaultAppBar() {
    return AppBar(
      backgroundColor: mainColor,
      elevation: 0,
      title: HeadingText("Chats"),
      actions: [
        InkWell(
          onTap: () {
            setState(() {
              _isSearching = true;
            });
          },
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedSearch01,
            color: Colors.black,
            size: 20.0,
          ),
        ),
        SizedBox(
          width: 16.0,
        )
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: primaryColor,
          height: 1.0,
        ),
      ),
    );
  }

  // Search AppBar
  AppBar _buildSearchAppBar() {
    return AppBar(
      backgroundColor: mainColor,
      elevation: 0,
      title: buildSearchBar(),
      leadingWidth: 20,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: mutedTextColor,
            size: 16.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color.fromARGB(255, 242, 242, 242),
          height: 1.0,
        ),
      ),
    );
  }
}
