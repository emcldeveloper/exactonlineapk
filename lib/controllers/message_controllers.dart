import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_online/controllers/chat_controller.dart';
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
  Future sendMessage({message, TopicId, from, UserId, type}) async {
    try {
      var response = await dio.post(
        "/messages/",
        data: {
          "message": message,
          "TopicId": TopicId,
          "from": from,
          "UserId": UserId,
          "type": type
        },
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );
      var data = response.data["body"];
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future getTopicMessages({topicId}) async {
    try {
      var response = await dio.get(
        "/messages/topic/$topicId",
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );
      var data = response.data["body"];
      print(data);
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future updateShopMessages({shopId}) async {
    try {
      var response = await dio.patch(
        "/messages/mark-as-read/shop/$shopId",
        data: {},
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );
      var data = response.data["body"];
      print(data);
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future updateUserMessages({userId}) async {
    try {
      var response = await dio.patch(
        "/messages/mark-as-read/user/$userId",
        data: {},
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );
      var data = response.data["body"];
      print(data);
      return data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Stream<List<Message>> getProductMessages({chatId, productId}) {
    return firestore
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .where("chatId", isEqualTo: chatId)
        .where("productId", isEqualTo: productId)
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
