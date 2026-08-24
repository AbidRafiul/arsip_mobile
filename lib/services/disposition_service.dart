import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/disposition_model.dart';

class DispositionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<DispositionItemModel>> getDispositionList({
    String? status,
    String? keyword,
  }) async {
    final payload = {
      if (status != null && status.isNotEmpty) 'status': status,
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
    };

    final response = await _apiClient.post(
      ApiConfig.endpointDispositionData,
      data: payload,
    );

    if (response.statusCode == 200 && response.data != null && response.data['status'] == true) {
      final List listRaw = response.data['data'] ?? [];
      return listRaw.map((e) => DispositionItemModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> processDisposition(int disposisiSuratId, {String? catatan}) async {
    final note = catatan ?? 'Disposisi diproses via aplikasi mobile';
    final response = await _apiClient.post(
      ApiConfig.endpointDispositionProcess,
      data: {
        'disposisi_id': disposisiSuratId,
        'disposisi_surat_id': disposisiSuratId,
        'id_disposisi': disposisiSuratId,
        'catatan': note,
        'process_note': note,
        'catatan_disposisi': note,
      },
    );

    return response.statusCode == 200 && response.data != null && response.data['status'] == true;
  }

  Future<bool> completeDisposition(int disposisiSuratId, {String? catatan}) async {
    final note = catatan ?? 'Disposisi diselesaikan via aplikasi mobile';
    final response = await _apiClient.post(
      ApiConfig.endpointDispositionComplete,
      data: {
        'disposisi_id': disposisiSuratId,
        'disposisi_surat_id': disposisiSuratId,
        'id_disposisi': disposisiSuratId,
        'catatan': note,
        'complete_note': note,
        'catatan_disposisi': note,
      },
    );

    return response.statusCode == 200 && response.data != null && response.data['status'] == true;
  }
}
