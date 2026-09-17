import '../core/network/api_client.dart';
import '../config/api_config.dart';
import '../models/buku_tamu_model.dart';

class BukuTamuService {
  final ApiClient _apiClient = ApiClient();

  Future<List<BukuTamuItem>> getVisitData({
    int page = 1,
    int limit = 30,
    String? status,
    String? approvalStatus,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'page': page,
        'limit': limit,
      };

      if (status != null) body['Status'] = status;
      if (approvalStatus != null) body['ApprovalStatus'] = approvalStatus;
      if (startDate != null && endDate != null) {
        body['TanggalMulai'] = startDate;
        body['TanggalSelesai'] = endDate;
      }

      final response = await _apiClient.post(
        ApiConfig.endpointVisitData,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List rows = response.data['data']?['rows'] ?? [];
        return rows.map((json) => BukuTamuItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Gagal memuat data buku tamu: $e');
    }
  }

  Future<Map<String, dynamic>?> getVisitDetail(int visitationId) async {
    try {
      final response = await _apiClient.post(
        '/buku-tamu/visit-detail',
        data: {'VisitationId': visitationId},
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      throw Exception('Gagal memuat detail tamu: $e');
    }
  }
}
