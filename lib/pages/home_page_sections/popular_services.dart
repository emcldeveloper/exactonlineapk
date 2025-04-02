import 'package:e_online/controllers/service_controller.dart';
import 'package:e_online/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularServices extends StatelessWidget {
  PopularServices({super.key});

  final RxList services = <dynamic>[].obs;
  final ScrollController _scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  int _currentPage = 1;
  final int _limit = 5;

  @override
  Widget build(BuildContext context) {
    _fetchServices(_currentPage); // Initial fetch
    _scrollController.addListener(_onScroll); // Attach scroll listener

    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 235,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            itemCount: services.length + (isLoading.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == services.length && isLoading.value) {
                return services.isNotEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 110.0),
                        child: SizedBox(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: ServiceCard(data: services[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _fetchServices(int page) async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    try {
      final res = await ServiceController().getPopularServices(
        page: page,
        limit: _limit,
        keyword: "",
      );
      final filteredRes =
          res.where((item) => item["ServiceImages"].isNotEmpty).toList();

      if (filteredRes.isEmpty || filteredRes.length < _limit) {
        hasMore.value = false;
      }

      if (page == 1) {
        services.value = filteredRes; // Replace the list
      } else {
        services.addAll(filteredRes); // Append new items
      }
    } catch (e) {
      Get.snackbar("Error", "Error loading services: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !isLoading.value &&
        hasMore.value) {
      _currentPage++;
      _fetchServices(_currentPage);
    }
  }
}
