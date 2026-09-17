import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/multi_dashboard_model.dart';

class MultiDashboardService {
  final ApiClient _apiClient = ApiClient();

  /// Ambil Statistik Agregat untuk Executive Summary
  Future<ExecutiveDashboardStats> getExecutiveStats() async {
    int pendingSurat = 0;
    int pendingLoan = 0;
    int pendingVersion = 0;
    int pendingVisit = 0;
    int pendingDestruction = 0;
    int activeDisposition = 0;

    // 1. Surat Keluar Pending
    try {
      final resSurat = await _apiClient.post(
        ApiConfig.endpointOutgoingApprovalData,
        data: {'status': 'menunggu_approval', 'limit': 1},
      );
      if (resSurat.statusCode == 200 && resSurat.data?['status'] == true) {
        pendingSurat = resSurat.data['pagination']?['total_data'] ?? 0;
      }
    } catch (_) {}

    // 2. Peminjaman Arsip Pending
    try {
      final resLoan = await _apiClient.get(
        ApiConfig.endpointArchiveLoanGet,
        queryParameters: {'status': 'pending'},
      );
      if (resLoan.statusCode == 200 && resLoan.data != null) {
        final List list = resLoan.data['data'] ?? resLoan.data['loans'] ?? [];
        pendingLoan = list.length;
      }
    } catch (_) {}

    // 3. Versi Dokumen Pending
    try {
      final resVersion = await _apiClient.get(
        ApiConfig.endpointDocumentVersionGet,
        queryParameters: {'status_persetujuan': 'pending'},
      );
      if (resVersion.statusCode == 200 && resVersion.data != null) {
        final List list = resVersion.data['data'] ?? resVersion.data['versions'] ?? [];
        pendingVersion = list.length;
      }
    } catch (_) {}

    // 4. Kunjungan Tamu Pending
    try {
      final resVisit = await _apiClient.post(
        ApiConfig.endpointVisitData,
        data: {'ApprovalStatus': 'pending', 'limit': 1},
      );
      if (resVisit.statusCode == 200 && resVisit.data != null) {
        pendingVisit = resVisit.data['data']?['total'] ?? 0;
      }
    } catch (_) {}

    // 5. Pemusnahan Arsip Submitted
    try {
      final resDestruction = await _apiClient.get(
        ApiConfig.endpointDestructionGet,
        queryParameters: {'status': 'submitted'},
      );
      if (resDestruction.statusCode == 200 && resDestruction.data != null) {
        final List list = resDestruction.data['data'] ?? resDestruction.data['proposals'] ?? [];
        pendingDestruction = list.length;
      }
    } catch (_) {}

    // 6. Disposisi Aktif
    try {
      final resDisp = await _apiClient.post(
        ApiConfig.endpointDispositionData,
        data: {},
      );
      if (resDisp.statusCode == 200 && resDisp.data?['status'] == true) {
        activeDisposition = resDisp.data['pagination']?['total_data'] ?? 0;
      }
    } catch (_) {}

    return ExecutiveDashboardStats(
      pendingSuratKeluar: pendingSurat,
      pendingPeminjamanArsip: pendingLoan,
      pendingVersiDokumen: pendingVersion,
      pendingBukuTamu: pendingVisit,
      pendingPemusnahanArsip: pendingDestruction,
      totalDisposisiAktif: activeDisposition,
    );
  }

  /// Ambil Statistik Modul Korespondensi
  Future<CorrespondenceDashboardStats> getCorrespondenceStats({String? startDate, String? endDate}) async {
    try {
      final query = <String, dynamic>{};
      if (startDate != null && endDate != null) {
        query['startDate'] = startDate;
        query['endDate'] = endDate;
      }
      final response = await _apiClient.get(ApiConfig.endpointOutgoingDashboardStats, queryParameters: query);
      if (response.statusCode == 200 && response.data != null && response.data['status'] == true) {
        final summaryMap = response.data['data']?['summary'] ?? {};
        return CorrespondenceDashboardStats.fromJson(summaryMap);
      }
    } catch (_) {}

    return CorrespondenceDashboardStats();
  }

  /// Ambil Statistik Modul Arsip Dokumen
  Future<ArsipDashboardStats> getArsipStats({String? startDate, String? endDate}) async {
    try {
      final query = <String, dynamic>{};
      if (startDate != null && endDate != null) {
        query['startDate'] = startDate;
        query['endDate'] = endDate;
      }
      final response = await _apiClient.get(ApiConfig.endpointArsipDashboardStats, queryParameters: query);
      if (response.statusCode == 200 && response.data != null) {
        final summaryMap = response.data['data']?['summary'] ?? response.data['summary'] ?? response.data['data'];
        if (summaryMap != null) {
          return ArsipDashboardStats.fromJson(summaryMap);
        }
      }
    } catch (_) {}

    return ArsipDashboardStats();
  }

  /// Ambil Statistik Modul Buku Tamu
  Future<BukuTamuDashboardStats> getBukuTamuStats({String? startDate, String? endDate}) async {
    int total = 0;
    int disetujui = 0;
    int ditolak = 0;
    int pending = 0;

    try {
      // Get Total (semua status)
      final resTotal = await _apiClient.post(ApiConfig.endpointVisitData, data: {'limit': 1, if (startDate != null) 'TanggalMulai': startDate, if (endDate != null) 'TanggalSelesai': endDate});
      if (resTotal.statusCode == 200 && resTotal.data != null) total = resTotal.data['data']?['total'] ?? 0;

      // Get Disetujui
      final resDisetujui = await _apiClient.post(ApiConfig.endpointVisitData, data: {'ApprovalStatus': 'disetujui', 'limit': 1, if (startDate != null) 'TanggalMulai': startDate, if (endDate != null) 'TanggalSelesai': endDate});
      if (resDisetujui.statusCode == 200 && resDisetujui.data != null) disetujui = resDisetujui.data['data']?['total'] ?? 0;

      // Get Ditolak
      final resDitolak = await _apiClient.post(ApiConfig.endpointVisitData, data: {'ApprovalStatus': 'ditolak', 'limit': 1, if (startDate != null) 'TanggalMulai': startDate, if (endDate != null) 'TanggalSelesai': endDate});
      if (resDitolak.statusCode == 200 && resDitolak.data != null) ditolak = resDitolak.data['data']?['total'] ?? 0;

      // Get Pending
      final resPending = await _apiClient.post(ApiConfig.endpointVisitData, data: {'ApprovalStatus': 'pending', 'limit': 1, if (startDate != null) 'TanggalMulai': startDate, if (endDate != null) 'TanggalSelesai': endDate});
      if (resPending.statusCode == 200 && resPending.data != null) pending = resPending.data['data']?['total'] ?? 0;

    } catch (e) {
      print('Error fetching real buku tamu stats: $e');
    }

    return BukuTamuDashboardStats(
      tamuHariIni: total, // We map total to tamuHariIni so the UI displays it as Total Tamu
      checkedIn: disetujui,
      checkedOut: ditolak,
      pendingApproval: pending,
    );
  }
}
