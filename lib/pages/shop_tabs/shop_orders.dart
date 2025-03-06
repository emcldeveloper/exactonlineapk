import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/pages/seller_order_view_page.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/order_card.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopOrders extends StatefulWidget {
  const ShopOrders({super.key});

  @override
  State<ShopOrders> createState() => _ShopOrdersState();
}

class _ShopOrdersState extends State<ShopOrders> {
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
      final res = await OrdersController().getShopOrders(page, _limit, "");

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
      backgroundColor: Colors.white,
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
                        await Get.to(SellerOrderViewPage(order: orders[index]));
                        setState(() {
                          _currentPage = 1;
                          _hasMore = true;
                          orders = [];
                          _fetchOrders(_currentPage);
                        });
                      },
                      child: Column(
                        children: [
                          OrderCard(
                            data: orders[index],
                            isUser: false,
                          ),
                          spacer2(),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
