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

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

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
      final res = await OrdersController().getMyOrders(page, _limit, "");

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios,
            color: mutedTextColor,
            size: 16.0,
          ),
        ),
        title: HeadingText("My Orders"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 242, 242, 242),
            height: 1.0,
          ),
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
                        setState(() {
                          _currentPage = 1;
                          _hasMore = true;
                          orders = [];
                          _fetchOrders(_currentPage);
                        });
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
    );
  }
}
