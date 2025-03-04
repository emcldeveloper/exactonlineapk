import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/message_controllers.dart';
import 'package:e_online/controllers/topic_controller.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/widgets/chatBubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:timeago/timeago.dart' as timeago;

class ConversationPage extends StatefulWidget {
  final Map<String, dynamic> topic;
  final bool isUser;
  const ConversationPage(this.topic, {this.isUser = true, super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final Map<String, dynamic> chatData =
      Get.arguments as Map<String, dynamic>? ?? {};
  late RxList messages; // Reactive list for messages
  final ScrollController _scrollController = ScrollController();
  final UserController userController = Get.find();
  final MessageController messageControllerInstance = MessageController();
  final TextEditingController messageController = TextEditingController();
  late IO.Socket socket; // Socket.IO client instance

  @override
  void initState() {
    super.initState();
    messages = RxList([]); // Initialize reactive list

    // Fetch initial messages
    messageControllerInstance
        .getTopicMessages(topicId: widget.topic["id"])
        .then((res) {
      messages.addAll(res);
      _scrollToBottom();
    });

    // Initialize Socket.IO connection
    _connectToSocket();
  }

  // Connect to Socket.IO server
  void _connectToSocket() {
    socket = IO.io('https://api.exactonline.co.tz', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    socket.on('receiveMessage', (data) {
      messages.add(data);
      _scrollToBottom();
    });

    socket.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });
  }

  // Scroll to the bottom of the ListView
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: TopicController().getTopic(id: widget.topic["id"]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('No topic data found'));
          }
          print(data);

          // Extract product images
          List<dynamic> productImages = data['Product'] != null &&
                  data['Product']['ProductImages'] != null
              ? data['Product']['ProductImages']
              : data["Order"]["OrderedProducts"][0]["Product"]["ProductImages"];

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // SliverAppBar with Carousel
              SliverAppBar(
                leadingWidth: 20,
                leading: InkWell(
                  onTap: () => Get.back(),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 16.0,
                    ),
                  ),
                ),
                backgroundColor: Colors.black,
                title: Text(
                  data['Product']?['name'] ??
                      "Order #${data["Order"]?["id"].toString().split("-").first}" ??
                      widget.topic["title"] ??
                      "Chat",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                expandedHeight: 205.0,
                floating: false,
                pinned: true,
                elevation: 0,
                snap: false,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero, // Remove default padding

                  background: Container(
                    color: mainColor,
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // Align content to top
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (productImages.isNotEmpty)
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 250.0, // Full height of expanded app bar
                              autoPlay: true,
                              aspectRatio: 1,
                              viewportFraction: 1,
                              padEnds: false,
                            ),
                            items: productImages.map((image) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: image['image'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 250.0, // Match carousel height
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                          Icons.error,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        height: 250.0,
                                        color: Colors.black.withAlpha(50),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }).toList(),
                          )
                        else
                          SizedBox(
                            height: 250.0,
                            child: Center(
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: mainColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(
                    color: const Color.fromARGB(255, 242, 242, 242),
                    height: 1.0,
                  ),
                ),
              ),
              // Sliver for the chat messages
              SliverFillRemaining(
                child: Column(
                  children: [
                    Expanded(
                      child: Obx(
                        () => ListView.builder(
                          reverse:
                              true, // Reverse the ListView to start from bottom
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final reversedIndex = messages.length - 1 - index;
                            return Align(
                              alignment: (widget.isUser &&
                                          messages[reversedIndex]["from"] ==
                                              "user") ||
                                      (!widget.isUser &&
                                          messages[reversedIndex]["from"] ==
                                              "shop")
                                  ? Alignment.bottomRight
                                  : Alignment.bottomLeft,
                              child: ChatBubble(
                                message: messages[reversedIndex],
                                text: messages[reversedIndex]["message"],
                                isSentByMe: (widget.isUser &&
                                            messages[reversedIndex]["from"] ==
                                                "user") ||
                                        (!widget.isUser &&
                                            messages[reversedIndex]["from"] ==
                                                "shop")
                                    ? true
                                    : false,
                                time: timeago.format(DateTime.parse(
                                    messages[reversedIndex]["createdAt"])),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Message input area
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Colors.grey.shade200, width: 1.0),
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
                            onTap: () async {
                              if (messageController.text.isNotEmpty) {
                                var text = messageController.text;
                                messageController.clear();
                                await messageControllerInstance.sendMessage(
                                  message: text,
                                  TopicId: widget.topic["id"],
                                  UserId: userController.user.value["id"],
                                  from: widget.isUser ? "user" : "shop",
                                );
                              }
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
