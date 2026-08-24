import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardSummaryModel> getSummaryStats() async {
    try {
      final response = await _apiClient.get(ApiConfig.endpointDashboardSummary);
      if (response.statusCode == 200 && response.data != null) {
        final summaryMap = response.data['data']?['summary'] ?? response.data['summary'] ?? {};
        return DashboardSummaryModel.fromJson(summaryMap);
      }
    } catch (e) {
      debugPrint("Dashboard summary fetch error: $e");
    }

    return DashboardSummaryModel(
      arsipAktif: 0,
      tamuHariIni: 0,
      menungguDisposisi: 0,
      retensiExpired: 0,
      total: 0,
    );
  }

  Future<List<AuditLogItem>> getRecentActivities() async {
    try {
      final response = await _apiClient.get(ApiConfig.endpointDashboardSummary);
      if (response.statusCode == 200 && response.data != null) {
        final List logsRaw = response.data['data']?['auditLogs'] ?? [];
        return logsRaw.map((e) => AuditLogItem.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }
}
