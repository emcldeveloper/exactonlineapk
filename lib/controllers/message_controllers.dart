import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_online/controllers/user_controller.dart';
import 'package:e_online/models/message.dart';
import 'package:e_online/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:e_online/utils/dio.dart';
import 'package:get/get.dart';

class MessageController extends GetxController {
  Rx<List<Message>> messagesReceiver = Rx<List<Message>>([]);
  List<Message> get messages => messagesReceiver.value;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future addMessage({message, orderId, from, productid, chatId}) async {
    try {
      var id = Timestamp.now().toDate().toLocal().toString();
      await firestore.collection("messages").doc(id).set({
        "id": id,
        "message": message,
        "chatId": chatId,
        "orderId": orderId,
        "from": from,
        "productId": productid,
        "createdAt": Timestamp.now()
      });
    } catch (e) {
      print(e);
    }
  }

  Stream<List<Message>> getMessages({chatId}) {
    return firestore
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .where("chatId", isEqualTo: chatId)
        .snapshots()
        .map((querySnapshot) {
      List<Message> messages = [];
      for (var doc in querySnapshot.docs) {
        messages.add(Message.fromDocumentSnapshot(doc));
      }
      return messages;
    });
  }
}
