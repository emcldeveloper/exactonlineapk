import 'package:e_online/constants/colors.dart';
import 'package:e_online/constants/product_items.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/pages/customer_order_view_page.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/order_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrdersPage extends StatefulWidget {
  String from;
  MyOrdersPage({super.key, this.from = "main"});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final ScrollController _scrollController = ScrollController();
  List orders = [];
  int _currentPage = 1;
  final int _limit = 10;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  var status = "NEW ORDER".obs;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logScreenView(
      screenName: "MyOrdersPage",
      screenClass: "MyOrdersPage",
    );
    _fetchOrders(_currentPage);
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchOrders(int page) async {
    if (page > 1 && (_isLoadingMore || !_hasMore)) return;

    if (page == 1) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final res =
          await OrdersController().getMyOrders(page, _limit, "", status.value);

      if (res.isEmpty || res.length < _limit) {
        _hasMore = false;
      }

      setState(() {
        if (page == 1) {
          orders = res;
        } else {
          orders = [...orders, ...res];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _currentPage++;
      _fetchOrders(_currentPage);
    }
  }

  void _refreshOrders() {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      orders = [];
    });
    _fetchOrders(_currentPage);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          backgroundColor: mainColor,
          shadowColor: Colors.white,
          foregroundColor: Colors.white,
          leadingWidth: widget.from == "cart" ? 16 : 1,
          leading: widget.from == "cart"
              ? InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      color: Colors.transparent,
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: mutedTextColor,
                        size: 16.0,
                      ),
                    ),
                  ))
              : Container(),
          title: HeadingText("My Orders"),
          centerTitle: widget.from == "cart" ? true : false,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Color.fromARGB(255, 234, 234, 234),
            indicatorSize: TabBarIndicatorSize.label,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            labelStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            onTap: (index) {
              // Update status based on tab selection
              switch (index) {
                case 0: // Pending tab
                  status.value = "NEW ORDER";
                  break;
                case 1: // Active tab
                  status.value = "IN PROGRESS";
                  break;
                case 2: // Delivered tab
                  status.value = "CONFIRMED";
                  break;
                case 3: // Delivered tab
                  status.value = "DELIVERED";
                  break;
                case 4: // Delivered tab
                  status.value = "CANCELED";
                  break;
              }
              _refreshOrders(); // Fetch orders with new status
            },
            tabs: const [
              Tab(text: "New Orders"),
              Tab(text: "In Progress"),
              Tab(text: "Confirmed Orders"),
              Tab(text: "Delivered Orders"),
              Tab(text: "Canceled Orders"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              )
            : orders.isEmpty
                ? noData()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: orders.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == orders.length && _isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () async {
                          await Get.to(
                              CustomerOrderViewPage(order: orders[index]));
                          _refreshOrders();
                        },
                        child: Column(
                          children: [
                            OrderCard(data: orders[index]),
                            spacer2(),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
