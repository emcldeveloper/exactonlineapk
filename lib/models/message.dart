import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  late String id;
  late String message;
  late String from;
  late String? orderId;
  late String? productId;
  late Timestamp createdAt;
  Message();
  Message.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot["id"];
    message = documentSnapshot["message"];
    from = documentSnapshot["from"];
    orderId = documentSnapshot["orderId"];
    productId = documentSnapshot["productId"];
    createdAt = documentSnapshot["createdAt"];
  }
}
