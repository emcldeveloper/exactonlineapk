import 'package:e_online/controllers/chat_controller.dart';
import 'package:e_online/pages/topics_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/shop_chat_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopChatPage extends StatefulWidget {
  ShopChatPage({super.key});

  @override
  State<ShopChatPage> createState() => _ShopChatPageState();
}

class _ShopChatPageState extends State<ShopChatPage> {
  @override
  void initState() {
    super.initState();
    trackScreenView("ShopChatPage");
  }

  final List<Map<String, dynamic>> chatItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: FutureBuilder(
          future: ChatController().getShopChats(1, 100, ""),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            }
            List chats = snapshot.requireData;
            return chats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No chats yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: chats.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return GestureDetector(
                        onTap: () async {
                          await Get.bottomSheet(
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: TopicsPage(
                                chat: chat,
                                from: "shop",
                                refreshPage: () {
                                  setState(() {});
                                },
                              ),
                            ),
                            isScrollControlled: true,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: shopChatCard(chat),
                        ),
                      );
                    },
                  );
          }),
    );
  }
}
