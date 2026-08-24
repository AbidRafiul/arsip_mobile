import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/approval_model.dart';

class ApprovalService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ApprovalItemModel>> getApprovalList({
    String? status,
    String? keyword,
    int page = 1,
    int limit = 20,
  }) async {
    final payload = {
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      'sort_by': 'created_at',
      'sort_order': 'desc',
    };

    final response = await _apiClient.post(
      ApiConfig.endpointOutgoingApprovalData,
      data: payload,
    );

    if (response.statusCode == 200 && response.data != null && response.data['status'] == true) {
      final List listRaw = response.data['data'] ?? [];
      return listRaw.map((e) => ApprovalItemModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getLetterDetail(int idSuratKeluar) async {
    final response = await _apiClient.get('${ApiConfig.endpointOutgoingDetail}/$idSuratKeluar');

    if (response.statusCode == 200 && response.data != null && response.data['status'] == true) {
      final dataMap = response.data['data'] ?? {};
      final surat = ApprovalItemModel.fromJson(dataMap['surat'] ?? {});
      final List filesRaw = dataMap['files'] ?? [];
      final List trackingsRaw = dataMap['trackings'] ?? [];

      final files = filesRaw.map((e) => FileSuratModel.fromJson(e)).toList();
      final trackings = trackingsRaw.map((e) => TrackingItemModel.fromJson(e)).toList();

      return {
        'surat': surat,
        'files': files,
        'trackings': trackings,
      };
    }
    throw Exception(response.data?['message'] ?? 'Gagal memuat detail surat');
  }

  Future<bool> approveLetter(int idSuratKeluar, {String? catatan}) async {
    final response = await _apiClient.post(
      ApiConfig.endpointOutgoingApprove,
      data: {
        'id_surat_keluar': idSuratKeluar,
        'catatan': catatan ?? 'Disetujui dari aplikasi mobile',
      },
    );

    if (response.statusCode == 200 && response.data != null && response.data['status'] == true) {
      return true;
    } else {
      throw Exception(response.data?['message'] ?? 'Gagal menyetujui surat');
    }
  }

  Future<bool> rejectLetter(int idSuratKeluar, {required String catatan}) async {
    final response = await _apiClient.post(
      ApiConfig.endpointOutgoingReject,
      data: {
        'id_surat_keluar': idSuratKeluar,
        'catatan': catatan,
      },
    );

    if (response.statusCode == 200 && response.data != null && response.data['status'] == true) {
      return true;
    } else {
      throw Exception(response.data?['message'] ?? 'Gagal menolak surat');
    }
  }
}
