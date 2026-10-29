import '../core/network/api_client.dart';
import '../models/arsip_model.dart';

class ArsipService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ArsipItem>> getDocuments({
    String? status,
    bool expiredOnly = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final String endpoint = expiredOnly 
          ? '/arsip-dokumen/retention/expired' 
          : '/arsip-dokumen/get';

      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List rows = response.data['data'] ?? response.data['documents'] ?? [];
        return rows.map((json) => ArsipItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Gagal memuat data arsip: $e');
    }
  }

  Future<Map<String, dynamic>?> getDocumentDetail(int documentId) async {
    try {
      final response = await _apiClient.get(
        '/arsip-dokumen/detail',
        queryParameters: {'id_dokumen': documentId},
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Gagal memuat detail arsip: $e');
    }
  }
}
