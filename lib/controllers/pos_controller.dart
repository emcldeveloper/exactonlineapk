import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../utils/dio.dart';
import '../utils/shared_preferences.dart';

class POSController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<dynamic> sales = <dynamic>[].obs;
  final RxList<dynamic> sessions = <dynamic>[].obs;
  final Rx<Map<String, dynamic>?> currentSession =
      Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> analytics = Rx<Map<String, dynamic>?>(null);

  // Create a new POS sale
  Future<Map<String, dynamic>?> createSale({
    required String shopId,
    required List<Map<String, dynamic>> items,
    required double total,
    required String paymentMethod,
    double subtotal = 0,
    double discount = 0,
    double tax = 0,
    double? amountPaid,
    String? customerName,
    String? customerPhone,
    String? customerId,
    String? notes,
    String? posSessionId,
  }) async {
    try {
      isLoading.value = true;

      // Validate items before sending
      for (var item in items) {
        if (item['id'] == null) {
          Get.snackbar('Error', 'Invalid product in cart (missing ID)');
          print('Invalid item in cart: $item');
          return null;
        }
      }

      final mappedItems = items
          .map((item) => {
                'ProductId': item['id'],
                'quantity': item['quantity'],
                'unitPrice': item['price'],
                'discount': item['discount'] ?? 0,
                'tax': item['tax'] ?? 0,
                'notes': item['notes'],
              })
          .toList();

      print('Mapped items to send: $mappedItems');

      // Map payment method to valid enum values
      String mappedPaymentMethod;
      if (paymentMethod.toLowerCase().contains('cash')) {
        mappedPaymentMethod = 'CASH';
      } else if (paymentMethod.toLowerCase().contains('card')) {
        mappedPaymentMethod = 'CARD';
      } else if (paymentMethod.toLowerCase().contains('mobile')) {
        mappedPaymentMethod = 'MOBILE_MONEY';
      } else if (paymentMethod.toLowerCase().contains('credit')) {
        mappedPaymentMethod = 'CREDIT';
      } else {
        mappedPaymentMethod = 'CASH'; // Default to CASH
      }

      print('Payment method: $paymentMethod -> $mappedPaymentMethod');

      final response = await dio.post(
        '/pos/sales',
        data: {
          'ShopId': shopId,
          'items': mappedItems,
          'subtotal': subtotal,
          'discount': discount,
          'tax': tax,
          'total': total,
          'paymentMethod': mappedPaymentMethod,
          'amountPaid': amountPaid ?? total,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'customerId': customerId,
          'notes': notes,
          'POSSessionId': posSessionId,
        },
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      Get.snackbar('Success', 'Sale completed successfully');
      return response.data['data'];
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to complete sale');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Get POS sales
  Future<List> getSales({
    String? shopId,
    DateTime? startDate,
    DateTime? endDate,
    String? paymentMethod,
    String? status,
    String? posSessionId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      isLoading.value = true;

      String url = '/pos/sales?page=$page&limit=$limit';
      if (shopId != null) url += '&ShopId=$shopId';
      if (paymentMethod != null) url += '&paymentMethod=$paymentMethod';
      if (status != null) url += '&status=$status';
      if (posSessionId != null) url += '&POSSessionId=$posSessionId';
      if (startDate != null) url += '&startDate=${startDate.toIso8601String()}';
      if (endDate != null) url += '&endDate=${endDate.toIso8601String()}';

      final response = await dio.get(
        url,
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      sales.value = response.data['data'] ?? [];
      return sales;
    } on DioException catch (e) {
      print(e.response);
      Get.snackbar('Error', 'Failed to fetch sales');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Get single sale
  Future<Map<String, dynamic>?> getSale(String id) async {
    try {
      isLoading.value = true;

      final response = await dio.get(
        '/pos/sales/$id',
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      return response.data['data'];
    } on DioException catch (e) {
      print(e.response);
      Get.snackbar('Error', 'Failed to fetch sale details');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Get POS analytics
  Future<Map<String, dynamic>?> getAnalytics({
    required String shopId,
    String period = 'today',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;

      String url = '/pos/analytics?ShopId=$shopId&period=$period';
      if (period == 'custom') {
        if (startDate != null)
          url += '&startDate=${startDate.toIso8601String()}';
        if (endDate != null) url += '&endDate=${endDate.toIso8601String()}';
      }

      final response = await dio.get(
        url,
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      analytics.value = response.data['data'];
      return analytics.value;
    } on DioException catch (e) {
      print(e.response);
      Get.snackbar('Error', 'Failed to fetch analytics');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Refund a sale
  Future<bool> refundSale({
    required String saleId,
    double? refundAmount,
    String? refundReason,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      isLoading.value = true;

      final response = await dio.post(
        '/pos/sales/$saleId/refund',
        data: {
          'refundAmount': refundAmount,
          'refundReason': refundReason,
          'items': items,
        },
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      Get.snackbar('Success', 'Sale refunded successfully');
      return true;
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to refund sale');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Start POS session
  Future<Map<String, dynamic>?> startSession({
    required String shopId,
    double openingCash = 0,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      final response = await dio.post(
        '/pos/sessions',
        data: {
          'ShopId': shopId,
          'openingCash': openingCash,
          'notes': notes,
        },
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      currentSession.value = response.data['data'];
      Get.snackbar('Success', 'Session opened successfully');
      return currentSession.value;
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to open session');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Close POS session
  Future<bool> closeSession({
    required String sessionId,
    required double closingCash,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      final response = await dio.patch(
        '/pos/sessions/$sessionId/close',
        data: {
          'closingCash': closingCash,
          'notes': notes,
        },
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      currentSession.value = null;
      Get.snackbar('Success', 'Session closed successfully');
      return true;
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to close session');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get POS sessions
  Future<List> getSessions({
    String? shopId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      isLoading.value = true;

      String url = '/pos/sessions?page=$page&limit=$limit';
      if (shopId != null) url += '&ShopId=$shopId';
      if (status != null) url += '&status=$status';

      final response = await dio.get(
        url,
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      sessions.value = response.data['data'] ?? [];
      return sessions;
    } on DioException catch (e) {
      print(e.response);
      Get.snackbar('Error', 'Failed to fetch sessions');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Get current open session
  Future<Map<String, dynamic>?> getCurrentSession(String shopId) async {
    try {
      final sessionsData =
          await getSessions(shopId: shopId, status: 'OPEN', limit: 1);
      if (sessionsData.isNotEmpty) {
        currentSession.value = sessionsData.first;
        return currentSession.value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
