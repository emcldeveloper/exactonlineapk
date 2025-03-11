import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/controllers/topic_controller.dart';
import 'package:e_online/pages/chat_page.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/favorite_card.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart';

class TopicsPage extends StatefulWidget {
  var chat;
  var from;
  TopicsPage({this.chat, this.from, super.key});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  Rx<List> topics = Rx<List>([]);
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 10; // Kept at 20 as per original code
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    trackScreenView("TopicsPage"); // Track this screen
    _fetchTopics(_currentPage); // Initial fetch
    _scrollController.addListener(_onScroll); // Attach scroll listener
  }

  Future<void> _fetchTopics(int page) async {
    if (_isLoading || !_hasMore)
      return; // Prevent multiple simultaneous fetches
    setState(() => _isLoading = true);

    try {
      final res = await TopicController()
          .getChatTopics(widget.chat["id"], page, _limit, "");
      final filteredRes = res;

      if (filteredRes.isEmpty || filteredRes.length < _limit) {
        _hasMore = false; // No more data to fetch
      }

      if (page == 1) {
        topics.value = filteredRes; // Replace for first page
      } else {
        topics.value = [
          ...topics.value,
          ...filteredRes
        ]; // Append for subsequent pages
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading topics: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        _hasMore) {
      _currentPage++;
      _fetchTopics(_currentPage);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 4,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            HeadingText(
                "Conversations with ${widget.from == null ? widget.chat["Shop"]["name"] : widget.chat["User"]["name"]}",
                fontSize: 18),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Obx(
                () => topics.value.isEmpty && !_isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      )
                    : ListView.builder(
                        controller:
                            _scrollController, // Attach ScrollController
                        itemCount: topics.value.length +
                            (_isLoading ? 1 : 0), // Add loading item
                        itemBuilder: (context, index) {
                          if (index == topics.value.length && _isLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }
                          var topic = topics.value[index];
                          print(topic);
                          return Container(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  if (topic["ProductId"] != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          Get.back();
                                          Get.to(() => ConversationPage(
                                                topic,
                                                isUser: widget.from == null,
                                              ));
                                        },
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: topic["Product"]
                                                              ['ProductImages']
                                                          ?[0]?["image"] ??
                                                      "",
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(
                                                          Icons.broken_image),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ParagraphText(
                                                      topic["Product"]["name"],
                                                      fontSize: 15),
                                                  ParagraphText(
                                                      "${topic["lastMessage"] ?? "No Message"}",
                                                      color: Colors.grey[500])
                                                ],
                                              ),
                                            ),
                                            Text(
                                              format(DateTime.parse(topic[
                                                      "lastMessageDatetime"] ??
                                                  topic["createdAt"])),
                                              style: TextStyle(fontSize: 12),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (topic["OrderId"] != null &&
                                      topic["Order"] != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          Get.back();
                                          Get.to(() => ConversationPage(
                                                topic,
                                                isUser: widget.from == null,
                                              ));
                                        },
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: topic["Order"][
                                                                      "OrderedProducts"]
                                                                  ?[
                                                                  0]?["Product"]
                                                              ?['ProductImages']
                                                          ?[0]?["image"] ??
                                                      "",
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(
                                                          Icons.broken_image),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ParagraphText(
                                                      "Order #${topic["Order"]?["id"].toString().split("-").first}" ??
                                                          "",
                                                      fontSize: 15),
                                                  ParagraphText(
                                                      "${topic["lastMessage"] ?? "No Message"}",
                                                      color: Colors.grey[500])
                                                ],
                                              ),
                                            ),
                                            Text(
                                              format(DateTime.parse(topic[
                                                      "lastMessageDatetime"] ??
                                                  topic["createdAt"])),
                                              style: TextStyle(fontSize: 12),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
