import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _apiClient.get(ApiConfig.endpointNotificationGet);
      if (response.statusCode == 200 && response.data != null) {
        final List rawData = response.data['data'] ?? [];
        return rawData.map((e) => AppNotification.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Gagal mengambil notifikasi: $e");
    }
    return [];
  }

  Future<bool> markAsRead({int? notificationId}) async {
    try {
      final data = notificationId != null ? {'id_notifikasi': notificationId} : {};
      final response = await _apiClient.put(
        ApiConfig.endpointNotificationMarkRead,
        data: data,
      );
      if (response.statusCode == 200 && response.data?['status'] == '00') {
        return true;
      }
    } catch (e) {
      debugPrint("Gagal update notifikasi: $e");
    }
    return false;
  }
}
