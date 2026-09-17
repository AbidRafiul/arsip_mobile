import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardSummaryModel> getSummaryStats({String? startDate, String? endDate}) async {
    try {
      final query = <String, dynamic>{};
      if (startDate != null && endDate != null) {
        query['startDate'] = startDate;
        query['endDate'] = endDate;
      }
      final response = await _apiClient.get(ApiConfig.endpointDashboardSummary, queryParameters: query);
      if (response.statusCode == 200 && response.data != null) {
        final summaryMap = response.data['data']?['summary'] ?? response.data['summary'] ?? {};
        
        // Fetch REAL tamu counts directly from DB so it matches the List Screen perfectly (ALL TIME or specific date)
        int realTamu = summaryMap['tamuHariIni'] ?? 0;
        try {
          final visitRes = await _apiClient.post(
            ApiConfig.endpointVisitData, 
            data: {
              'limit': 1, 
              if (startDate != null) 'TanggalMulai': startDate, 
              if (endDate != null) 'TanggalSelesai': endDate
            }
          );
          if (visitRes.statusCode == 200 && visitRes.data != null) {
            realTamu = visitRes.data['data']?['total'] ?? realTamu;
          }
        } catch (_) {}

        summaryMap['tamuHariIni'] = realTamu;
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
