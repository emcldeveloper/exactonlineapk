import 'package:e_online/controllers/order_controller.dart';
import 'package:e_online/controllers/topic_controller.dart';
import 'package:e_online/pages/conversation_page.dart';
import 'package:e_online/pages/customer_order_view_page.dart';
import 'package:e_online/pages/seller_order_view_page.dart';
import 'package:get/get.dart';

Future<void> handleNotificationNavigation(Map<String, dynamic> data) async {
  try {
    if (data['type'] == 'order') {
      final orderId = data['orderId']?.toString();
      if (orderId == null) return;
      final order = await OrdersController().getOrder(id: orderId);
      if (order == null) return;
      if (data['to'] == 'user') {
        Get.to(() => CustomerOrderViewPage(order: order));
      } else {
        Get.to(() => SellerOrderViewPage(order: order));
      }
      return;
    }

    if (data['type'] == 'message') {
      final topicId = data['topicId']?.toString();
      if (topicId == null) return;
      final topic = await TopicController().getTopic(id: topicId);
      if (topic == null) return;
      final bool isUser = data['to'] == 'user';
      Get.to(() => ConversationPage(topic, isUser: isUser));
      return;
    }
  } catch (e) {
    // Ignore navigation errors
  }
}
