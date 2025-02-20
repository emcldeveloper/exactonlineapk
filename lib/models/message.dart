import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/controllers/search_controller.dart';
import 'package:get/get.dart';

class Message {
  late String id;
  late String message;
  late String from;
  late String? orderId;
  Rx<Map<String, dynamic>> product = Rx<Map<String, dynamic>>({});
  Rx<Map<String, dynamic>> order = Rx<Map<String, dynamic>>({});
  late String? productId;
  late Timestamp createdAt;
  bool hasProduct() {
    return productId != null;
  }

  bool hasOrder() {
    return orderId != null;
  }

  Message();
  Message.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot["id"];
    message = documentSnapshot["message"];
    from = documentSnapshot["from"];
    orderId = documentSnapshot["orderId"];
    productId = documentSnapshot["productId"];
    if (productId != null) {
      ProductController().getProduct(id: productId).then((res) {
        print(res);
        product.value = res;
      });
    }
    if (orderId != null) {
      OrdersController().getOrder(id: orderId).then((res) {
        print(res);
        order.value = res;
      });
    }
    createdAt = documentSnapshot["createdAt"];
  }
}
