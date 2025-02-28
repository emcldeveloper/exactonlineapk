import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/message_controllers.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/models/message.dart';
import 'package:e_online/pages/customer_order_view_page.dart';
import 'package:e_online/pages/product_page.dart';
import 'package:e_online/pages/viewImage.dart';
import 'package:e_online/utils/convert_to_money_format.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/showProductInChat.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:timeago/timeago.dart' as timeago;

class ConversationPage extends StatefulWidget {
  Map<String, dynamic> topic;
  ConversationPage(this.topic, {super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final Map<String, dynamic> chatData =
      Get.arguments as Map<String, dynamic>? ?? {};
  final List<String> messages = [];
  final ScrollController _scrollController = ScrollController();

  UserController userController = Get.find();
//check if is person or user
  // bool isUser() {
  //   bool isUser = true;
  //   if (widget.chat["UserId"] != userController.user.value["id"]) {
  //     isUser = false;
  //   }
  //   return isUser;
  // }

  TextEditingController messageController = TextEditingController();

  // List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        leadingWidth: 20,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
              size: 16.0,
            ),
          ),
        ),
        title: Row(
          children: [
            // ClipOval(
            //     child: isUser()
            //         ? widget.chat["Shop"]["shopImage"] != null
            //             ? Container(
            //                 height: 30,
            //                 width: 30,
            //                 child: CachedNetworkImage(
            //                   imageUrl: widget.chat["Shop"]["shopImage"],
            //                   fit: BoxFit.cover,
            //                 ),
            //               )
            //             : Container(
            //                 color: Colors.grey[200],
            //                 child: const Padding(
            //                   padding: EdgeInsets.all(8.0),
            //                   child: Icon(Bootstrap.shop),
            //                 ),
            //               )
            //         // : widget.chat["User"]["image"] != null
            //         //     ? Container(
            //         //         height: 30,
            //         //         width: 30,
            //         //         child: CachedNetworkImage(
            //         //           imageUrl: widget.chat["User"]["image"],
            //         //           fit: BoxFit.cover,
            //         //         ),
            //         //       )
            //             : Container(
            //                 color: Colors.grey[200],
            //                 child: const Padding(
            //                   padding: EdgeInsets.all(8.0),
            //                   child: Icon(Bootstrap.person),
            //                 ),
            //               )),
            const SizedBox(width: 8),
            // HeadingText(isUser()
            //     ? widget.chat["Shop"]["name"]
            //     : widget.chat["User"]["name"])
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
        ),
      ),
      body: GetX<MessageController>(
          init: MessageController(),
          builder: (find) {
            return Column(
              children: [
                // if (widget.order != null)
                //   GestureDetector(
                //     onTap: () {
                //       Get.back();
                //     },
                //     child: Container(
                //       color: Colors.grey[100],
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 20, vertical: 5),
                //         child: Row(
                //           children: [
                //             ClipRRect(
                //               borderRadius: BorderRadius.circular(10),
                //               child: Container(
                //                   width: 80,
                //                   height: 80,
                //                   child: CachedNetworkImage(
                //                       imageUrl: widget.order!["Products"]
                //                               [0]["ProductImages"][0]
                //                           ["image"])),
                //             ),
                //             SizedBox(
                //               width: 10,
                //             ),
                //             Column(
                //               crossAxisAlignment:
                //                   CrossAxisAlignment.start,
                //               children: [
                //                 HeadingText(
                //                     "Order: ${widget.order!["id"].toString().split("-").last}",
                //                     fontSize: 14),
                //                 ParagraphText(
                //                     "This is conversation about this order",
                //                     fontSize: 12)
                //               ],
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // if (widget.product != null)
                //   GestureDetector(
                //     onTap: () {
                //       Get.to(() =>
                //           ProductPage(productData: widget.product!));
                //     },
                //     child: Container(
                //       color: Colors.grey[100],
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 20, vertical: 5),
                //         child: Row(
                //           children: [
                //             ClipRRect(
                //               borderRadius: BorderRadius.circular(10),
                //               child: Container(
                //                   width: 80,
                //                   height: 80,
                //                   child: CachedNetworkImage(
                //                       fit: BoxFit.cover,
                //                       imageUrl:
                //                           widget.product!["ProductImages"]
                //                               [0]["image"])),
                //             ),
                //             SizedBox(
                //               width: 10,
                //             ),
                //             Column(
                //               crossAxisAlignment:
                //                   CrossAxisAlignment.start,
                //               children: [
                //                 HeadingText("${widget.product!["name"]}",
                //                     fontSize: 14),
                //                 ParagraphText(
                //                     "TZS ${toMoneyFormmat(widget.product!["sellingPrice"])}",
                //                     fontSize: 12),
                //                 ParagraphText(
                //                     "This is conversation about this product",
                //                     fontSize: 12)
                //               ],
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Reverse the list to start from the bottom
                    padding: const EdgeInsets.all(16.0),
                    itemCount: messages.length, // Includes the initial message
                    itemBuilder: (context, index) {
                      // Correctly access the reversed index for the messages
                      // return Align(
                      //   alignment: (isUser() &&
                      //               messages[index].from == "user") ||
                      //           (!isUser() &&
                      //               messages[index].from == "shop")
                      //       ? Alignment.bottomRight
                      //       : Alignment.bottomLeft,
                      //   child: ChatBubble(
                      //     message: messages[index],
                      //     text: messages[index].message,
                      //     isSentByMe: (isUser() &&
                      //                 messages[index].from == "user") ||
                      //             (!isUser() &&
                      //                 messages[index].from == "shop")
                      //         ? true
                      //         : false,
                      //     time: timeago
                      //         .format(messages[index].createdAt.toDate()),
                      //   ),
                      // );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1.0),
                    ),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            fillColor: Colors.grey[100],
                            filled: true,
                            hintText: "Write your message here",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          // find
                          //     .addMessage(
                          //         chatId: widget.chat["id"],
                          //         productId: widget.product != null
                          //             ? widget.product!["id"]
                          //             : null,
                          //         orderId: widget.order != null
                          //             ? widget.order!["id"]
                          //             : null,
                          //         message: messageController.text,
                          //         from: isUser() ? "user" : "shop")
                          //     .then((res) {
                          //   messageController.text = "";
                          // });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(13.0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Transform.rotate(
                            angle: 6.3,
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedSent,
                              color: Colors.white,
                              size: 22.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            );
          }),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final String text;
  final bool isSentByMe;
  final String time;

  ChatBubble(
      {required this.message,
      required this.text,
      required this.isSentByMe,
      required this.time,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // if (message.hasOrder())
          //   GestureDetector(
          //       onTap: () {
          //         Get.to(
          //             () => CustomerOrderViewPage(order: message.order.value));
          //       },
          //       child:
          //           ParagraphText("View Order", fontWeight: FontWeight.bold)),
          // if (message.hasProduct())
          //   GestureDetector(
          //       onTap: () {
          //         showProductInChat(message);
          //       },
          //       child:
          //           ParagraphText("View Product", fontWeight: FontWeight.bold)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSentByMe ? primary.withOpacity(0.4) : Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isSentByMe ? 12 : 0),
                bottomRight: Radius.circular(isSentByMe ? 0 : 12),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}
