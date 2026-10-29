import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/unified_approval_model.dart';

class ApprovalUnifiedService {
  final ApiClient _apiClient = ApiClient();

  /// Mengambil daftar approval berdasarkan kategori
  Future<List<UnifiedApprovalItem>> getApprovalList({
    ApprovalCategory? category,
    String? keyword,
    int page = 1,
    int limit = 30,
  }) async {
    List<UnifiedApprovalItem> items = [];

    // 1. Surat Keluar
    if (category == null || category == ApprovalCategory.outgoingLetter) {
      try {
        final response = await _apiClient.post(
          ApiConfig.endpointOutgoingApprovalData,
          data: {
            'page': page,
            'limit': limit,
            'status': 'menunggu_approval',
            if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
          },
        );
        if (response.statusCode == 200 && (response.data?['status'] == true || response.data?['status'] == '00' || response.data?['status'] == 'success')) {
          final List listRaw = response.data['data'] ?? [];
          items.addAll(listRaw.map((e) => UnifiedApprovalItem.fromOutgoingLetter(e)));
        }
      } catch (_) {}
    }

    // 2. Disposisi Surat Masuk
    if (category == null || category == ApprovalCategory.disposition) {
      try {
        final response = await _apiClient.post(
          ApiConfig.endpointDispositionData,
          data: {
            if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
          },
        );
        if (response.statusCode == 200 && (response.data?['status'] == true || response.data?['status'] == '00' || response.data?['status'] == 'success')) {
          final List listRaw = response.data['data'] ?? [];
          final pendingList = listRaw.where((e) => e['status']?.toString().toLowerCase() != 'selesai').toList();
          items.addAll(pendingList.map((e) => UnifiedApprovalItem.fromDisposition(e)));
        }
      } catch (_) {}
    }

    // 3. Peminjaman Arsip
    if (category == null || category == ApprovalCategory.archiveLoan) {
      try {
        final response = await _apiClient.get(
          ApiConfig.endpointArchiveLoanGet,
          queryParameters: {'status': 'pending'},
        );
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'];
          List listRaw = [];
          if (data is List) {
            listRaw = data;
          } else if (data is Map) {
            listRaw = data['loans'] ?? data['data'] ?? data['rows'] ?? [];
          } else if (response.data['loans'] is List) {
            listRaw = response.data['loans'];
          }
          items.addAll(listRaw.map((e) => UnifiedApprovalItem.fromArchiveLoan(e)));
        }
      } catch (e) {
        print('Error parsing ArchiveLoan: \$e');
      }
    }

    // 4. Versi Dokumen
    if (category == null || category == ApprovalCategory.documentVersion) {
      try {
        final response = await _apiClient.get(
          ApiConfig.endpointDocumentVersionGet,
          queryParameters: {'status_persetujuan': 'pending'},
        );
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'];
          List listRaw = [];
          if (data is List) {
            listRaw = data;
          } else if (data is Map) {
            listRaw = data['versions'] ?? data['data'] ?? data['rows'] ?? [];
          } else if (response.data['versions'] is List) {
            listRaw = response.data['versions'];
          }
          items.addAll(listRaw.map((e) => UnifiedApprovalItem.fromDocumentVersion(e)));
        }
      } catch (e) {
        print('Error parsing DocumentVersion: \$e');
      }
    }

    // 5. Kunjungan Tamu
    if (category == null || category == ApprovalCategory.guestVisit) {
      try {
        final response = await _apiClient.post(
          ApiConfig.endpointVisitData,
          data: {
            'ApprovalStatus': 'pending',
            'page': page,
            'limit': limit,
          },
        );
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'];
          List listRaw = [];
          if (data is List) {
            listRaw = data;
          } else if (data is Map) {
            listRaw = data['rows'] ?? data['data'] ?? [];
          }
          for (var e in listRaw) {
            try {
              items.add(UnifiedApprovalItem.fromGuestVisit(Map<String, dynamic>.from(e)));
            } catch (err, stack) {
              items.add(UnifiedApprovalItem(
                id: -99,
                category: ApprovalCategory.guestVisit,
                title: 'Parsing Error',
                subtitle: err.toString(),
                date: '-',
                status: 'error',
                rawData: {},
              ));
            }
          }
        }
      } catch (e) {
        items.add(UnifiedApprovalItem(
          id: -100,
          category: ApprovalCategory.guestVisit,
          title: 'API Error',
          subtitle: e.toString(),
          date: '-',
          status: 'error',
          rawData: {},
        ));
      }
    }

    // 6. Pemusnahan Arsip JRA
    if (category == null || category == ApprovalCategory.destructionProposal) {
      try {
        final response = await _apiClient.get(
          ApiConfig.endpointDestructionGet,
          queryParameters: {'status': 'submitted'},
        );
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'];
          List listRaw = [];
          if (data is List) {
            listRaw = data;
          } else if (data is Map) {
            listRaw = data['proposals'] ?? data['data'] ?? data['rows'] ?? [];
          } else if (response.data['proposals'] is List) {
            listRaw = response.data['proposals'];
          }
          items.addAll(listRaw.map((e) => UnifiedApprovalItem.fromDestructionProposal(e)));
        }
      } catch (e) {
        print('Error parsing DestructionProposal: \$e');
      }
    }

    return items;
  }

  /// Eksekusi Aksi Approve / Persetujuan
  Future<bool> approveItem(UnifiedApprovalItem item, {String? notes}) async {
    final noteText = notes ?? 'Disetujui dari aplikasi Mobile Approval';

    switch (item.category) {
      case ApprovalCategory.outgoingLetter:
        final res = await _apiClient.post(
          ApiConfig.endpointOutgoingApprove,
          data: {'id_surat_keluar': item.id, 'catatan': noteText},
        );
        return res.statusCode == 200 && (res.data?['status'] == true || res.data?['status'] == '00');

      case ApprovalCategory.disposition:
        final res = await _apiClient.post(
          ApiConfig.endpointDispositionComplete,
          data: {
            'disposisi_id': item.id,
            'complete_note': noteText,
          },
        );
        return res.statusCode == 200;

      case ApprovalCategory.archiveLoan:
        final res = await _apiClient.post(
          ApiConfig.endpointArchiveLoanApprove,
          data: {
            'id_peminjaman': item.id,
            'status': 'approved',
            'catatan_persetujuan': noteText,
          },
        );
        return res.statusCode == 200;

      case ApprovalCategory.documentVersion:
        final res = await _apiClient.post(
          ApiConfig.endpointDocumentVersionApprove,
          data: {
            'id_versi': item.id,
            'status': 'approved',
            'catatan_persetujuan': noteText,
          },
        );
        return res.statusCode == 200;

      case ApprovalCategory.guestVisit:
        final res = await _apiClient.post(
          ApiConfig.endpointVisitApproval,
          data: {
            'idKunjungan': item.id,
            'action': 'approved',
            'catatanPersetujuan': noteText,
          },
        );
        return res.statusCode == 200;

      case ApprovalCategory.destructionProposal:
        final res = await _apiClient.post(
          ApiConfig.endpointDestructionReview,
          data: {
            'id_usulan': item.id,
            'status': 'approved',
            'catatan_tinjauan': noteText,
          },
        );
        return res.statusCode == 200;
    }
  }

  /// Eksekusi Aksi Reject / Penolakan
  Future<bool> rejectItem(UnifiedApprovalItem item, {required String notes}) async {
    switch (item.category) {
      case ApprovalCategory.outgoingLetter:
        final res = await _apiClient.post(
          ApiConfig.endpointOutgoingReject,
          data: {'id_surat_keluar': item.id, 'catatan': notes},
        );
        return res.statusCode == 200 && (res.data?['status'] == true || res.data?['status'] == '00');

      case ApprovalCategory.disposition:
        final res = await _apiClient.post(
          ApiConfig.endpointDispositionProcess,
          data: {
            'disposisi_id': item.id,
            'id_disposisi': item.id,
            'process_note': notes,
            'catatan': notes,
          },
        );
        return res.statusCode == 200;

      case ApprovalCategory.archiveLoan:
        final res = await _apiClient.post(
          ApiConfig.endpointArchiveLoanApprove,
          data: {
            'id_peminjaman': item.id,
            'status': 'rejected',
            'catatan_persetujuan': notes,
          },
        );
        return res.statusCode == 200;

      case ApprovalCategory.documentVersion:
        final res = await _apiClient.post(
          ApiConfig.endpointDocumentVersionApprove,
          data: {
            'id_versi': item.id,
            'status': 'rejected',
            'catatan_persetujuan': notes,
          },
        );
        return res.statusCode == 200;

      case ApprovalCategory.guestVisit:
        final res = await _apiClient.post(
          ApiConfig.endpointVisitApproval,
          data: {
            'idKunjungan': item.id,
            'action': 'rejected',
            'catatanPersetujuan': notes,
          },
        );
        return res.statusCode == 200;

      case ApprovalCategory.destructionProposal:
        final res = await _apiClient.post(
          ApiConfig.endpointDestructionReview,
          data: {
            'id_usulan': item.id,
            'status': 'rejected',
            'catatan_tinjauan': notes,
          },
        );
        return res.statusCode == 200;
    }
  }
}
