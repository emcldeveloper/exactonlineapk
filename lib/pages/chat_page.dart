import 'package:e_online/constants/colors.dart';
import 'package:e_online/pages/search_page.dart';
import 'package:e_online/widgets/chat_card.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key});

  final List<Map<dynamic, dynamic>> chatItems = [
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
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        title: HeadingText("Chats"),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(SearchPage());
            },
            icon: Icon(Icons.search),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: primaryColor,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: chatItems.map((chat) {
              return GestureDetector(
                onTap: () {
                  // Navigate to ConversationPage with data
                  Get.toNamed('/conversation', arguments: chat);
                },
                child: ChatCard(chat),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
