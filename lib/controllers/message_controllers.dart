// ignore_for_file: non_constant_identifier_names, empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
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
    } on DioException {}
  }

  Future getTopicMessages({topicId}) async {
    try {
      var response = await dio.get(
        "/messages/topic/$topicId",
        options: CacheOptions(
          store: MemCacheStore(),
          policy: CachePolicy.noCache, // Disable caching for this request
        ).toOptions().copyWith(
          headers: {
            "Authorization":
                "Bearer ${await SharedPreferencesUtil.getAccessToken()}",
          },
        ),
      );
      var data = response.data["body"];
      return data;
    } on DioException {}
  }

  Future updateShopMessages({shopId, chatId}) async {
    try {
      var response = await dio.patch(
        "/messages/mark-as-read/shop/$shopId/?ChatId=$chatId",
        data: {},
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );
      var data = response.data["body"];
      return data;
    } on DioException {}
  }

  Future updateUserMessages({userId, chatId}) async {
    try {
      var response = await dio.patch(
        "/messages/mark-as-read/user/$userId?ChatId=$chatId",
        data: {},
        options: Options(headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesUtil.getAccessToken()}"
        }),
      );
      var data = response.data["body"];
      return data;
    } on DioException {}
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
