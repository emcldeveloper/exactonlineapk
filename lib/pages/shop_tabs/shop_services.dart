import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/service_controller.dart';
import 'package:e_online/pages/add_service_page.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/shop_service_card.dart';

class ShopServices extends StatefulWidget {
  const ShopServices({super.key});

  @override
  State<ShopServices> createState() => _ShopServicesState();
}

class _ShopServicesState extends State<ShopServices> {
  final ScrollController _scrollController = ScrollController();
  List services = [];
  int _currentPage = 1;
  final int _limit = 6;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchServices(_currentPage);
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchServices(int page) async {
    if (page > 1 && (_isLoadingMore || !_hasMore)) return;

    if (page == 1) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final res = await ServiceController().getShopServices(
        page: page,
        limit: _limit,
      );

      if (res.isEmpty || res.length < _limit) {
        _hasMore = false;
      }

      setState(() {
        if (page == 1) {
          services = res;
        } else {
          services = [...services, ...res];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading services: $e')),
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
      _fetchServices(_currentPage);
    }
  }

  void onDelete() {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      services = [];
      _fetchServices(_currentPage);
    });
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
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Services",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Get.to(() => const AddServicePage());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : services.isEmpty
                ? noData()
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: services.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == services.length && _isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        );
                      }
                      return services[index]['ServiceImages'].length > 0
                          ? ShopServiceCard(
                              data: services[index],
                              onDelete: onDelete,
                            )
                          : Container();
                    },
                  ),
      ),
    );
  }
}
