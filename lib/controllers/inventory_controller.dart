import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../utils/dio.dart';
import '../utils/shared_preferences.dart';

class InventoryController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<dynamic> transactions = <dynamic>[].obs;
  final RxList<dynamic> batches = <dynamic>[].obs;
  final RxList<dynamic> alerts = <dynamic>[].obs;
  final Rx<Map<String, dynamic>?> inventorySettings =
      Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> inventoryStats =
      Rx<Map<String, dynamic>?>(null);

  // Add inventory transaction
  Future<bool> addInventoryTransaction({
    required String productId,
    required String shopId,
    required String transactionType,
    required int quantityChange,
    String? batchNumber,
    String? reference,
    String? notes,
    double? unitCost,
  }) async {
    try {
      isLoading.value = true;

      final response = await dio.post(
        '/inventory/transactions',
        data: {
          'ProductId': productId,
          'ShopId': shopId,
          'transactionType': transactionType,
          'quantityChange': quantityChange,
          'batchNumber': batchNumber,
          'reference': reference,
          'notes': notes,
          'unitCost': unitCost,
        },
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      Get.snackbar('Success', 'Transaction recorded successfully');
      return true;
    } on DioException catch (e) {
      Get.snackbar('Error',
          e.response?.data['message'] ?? 'Failed to record transaction');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get inventory transactions
  Future<List> getInventoryTransactions({
    String? productId,
    String? shopId,
    String? transactionType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      isLoading.value = true;

      String url = '/inventory/transactions?limit=$limit';
      if (productId != null) url += '&ProductId=$productId';
      if (shopId != null) url += '&ShopId=$shopId';
      if (transactionType != null) url += '&transactionType=$transactionType';
      if (startDate != null) url += '&startDate=${startDate.toIso8601String()}';
      if (endDate != null) url += '&endDate=${endDate.toIso8601String()}';

      final response = await dio.get(
        url,
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      final data = response.data['body'];
      transactions.value = data['transactions'] ?? [];
      return transactions;
    } on DioException catch (e) {
      print(e.response);
      Get.snackbar('Error', 'Failed to fetch transactions');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Add inventory batch
  Future<bool> addInventoryBatch({
    required String productId,
    required String shopId,
    required String batchNumber,
    required int quantity,
    DateTime? expiryDate,
    DateTime? manufacturingDate,
    Map<String, dynamic>? supplierInfo,
    double? costPerUnit,
    String? location,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      final response = await dio.post(
        '/inventory/batches',
        data: {
          'ProductId': productId,
          'ShopId': shopId,
          'batchNumber': batchNumber,
          'quantity': quantity,
          'expiryDate': expiryDate?.toIso8601String(),
          'manufacturingDate': manufacturingDate?.toIso8601String(),
          'supplierInfo': supplierInfo,
          'costPerUnit': costPerUnit,
          'location': location,
          'notes': notes,
        },
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      Get.snackbar('Success', 'Batch added successfully');
      return true;
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to add batch');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get inventory batches
  Future<List> getInventoryBatches({
    String? productId,
    String? shopId,
    String? status,
  }) async {
    try {
      isLoading.value = true;

      String url = '/inventory/batches?';
      if (productId != null) url += 'ProductId=$productId&';
      if (shopId != null) url += 'ShopId=$shopId&';
      if (status != null) url += 'status=$status';

      final response = await dio.get(
        url,
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      batches.value = response.data['body'] ?? [];
      return batches;
    } on DioException catch (e) {
      print(e.response);
      Get.snackbar('Error', 'Failed to fetch batches');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Get inventory alerts
  Future<List> getInventoryAlerts({
    String? shopId,
    bool? isResolved,
    String? severity,
  }) async {
    try {
      isLoading.value = true;

      String url = '/inventory/alerts?';
      if (shopId != null) url += 'ShopId=$shopId&';
      if (isResolved != null) url += 'isResolved=$isResolved&';
      if (severity != null) url += 'severity=$severity';

      final response = await dio.get(
        url,
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      final data = response.data['body'];
      alerts.value = data['alerts'] ?? [];
      return alerts;
    } on DioException catch (e) {
      print(e.response);
      Get.snackbar('Error', 'Failed to fetch alerts');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Update inventory alert
  Future<bool> updateInventoryAlert({
    required String alertId,
    bool? isRead,
    bool? isResolved,
  }) async {
    try {
      isLoading.value = true;

      final response = await dio.patch(
        '/inventory/alerts/$alertId',
        data: {
          'isRead': isRead,
          'isResolved': isResolved,
        },
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      return true;
    } on DioException catch (e) {
      Get.snackbar('Error', 'Failed to update alert');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get inventory settings
  Future getInventorySettings(String productId) async {
    try {
      isLoading.value = true;

      final response = await dio.get(
        '/inventory/settings/$productId',
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      inventorySettings.value = response.data['body'];
      return response.data['body'];
    } on DioException catch (e) {
      print(e.response);
      Get.snackbar('Error', 'Failed to fetch inventory settings');
    } finally {
      isLoading.value = false;
    }
  }

  // Update inventory settings
  Future<bool> updateInventorySettings({
    required String productId,
    bool? trackInventory,
    int? lowStockThreshold,
    int? reorderLevel,
    int? maxStockLevel,
    bool? allowBackorder,
    bool? enableLowStockAlert,
    bool? enableExpiryTracking,
    int? expiryAlertDays,
    String? stockValuationMethod,
    String? sku,
    String? barcode,
    String? location,
    String? supplier,
    int? leadTimeDays,
    double? buyingPrice,
  }) async {
    try {
      isLoading.value = true;

      final body = <String, dynamic>{};
      if (trackInventory != null) body['trackInventory'] = trackInventory;
      if (lowStockThreshold != null) {
        body['lowStockThreshold'] = lowStockThreshold;
      }
      if (reorderLevel != null) body['reorderLevel'] = reorderLevel;
      if (maxStockLevel != null) body['maxStockLevel'] = maxStockLevel;
      if (allowBackorder != null) body['allowBackorder'] = allowBackorder;
      if (enableLowStockAlert != null) {
        body['enableLowStockAlert'] = enableLowStockAlert;
      }
      if (enableExpiryTracking != null) {
        body['enableExpiryTracking'] = enableExpiryTracking;
      }
      if (expiryAlertDays != null) body['expiryAlertDays'] = expiryAlertDays;
      if (stockValuationMethod != null) {
        body['stockValuationMethod'] = stockValuationMethod;
      }
      if (sku != null) body['sku'] = sku;
      if (barcode != null) body['barcode'] = barcode;
      if (location != null) body['location'] = location;
      if (supplier != null) body['supplier'] = supplier;
      if (leadTimeDays != null) body['leadTimeDays'] = leadTimeDays;
      if (buyingPrice != null) body['buyingPrice'] = buyingPrice;

      final response = await dio.put(
        '/inventory/settings/$productId',
        data: body,
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      Get.snackbar('Success', 'Settings updated successfully');
      return true;
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to update settings');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get inventory stats
  Future getInventoryStats(String shopId) async {
    try {
      isLoading.value = true;

      final response = await dio.get(
        '/inventory/stats/$shopId',
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      inventoryStats.value = response.data['data'];
      return response.data['data'];
    } on DioException catch (e) {
      print(e.response);
      Get.snackbar('Error', 'Failed to fetch inventory stats');
    } finally {
      isLoading.value = false;
    }
  }

  // Bulk update inventory
  Future<bool> bulkUpdateInventory({
    required String shopId,
    required List<Map<String, dynamic>> products,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      final response = await dio.post(
        '/inventory/bulk-update',
        data: {
          'ShopId': shopId,
          'products': products,
          'notes': notes,
        },
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SharedPreferencesUtil.getAccessToken()}'
        }),
      );

      Get.snackbar('Success', 'Inventory updated successfully');
      return true;
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to update inventory');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
