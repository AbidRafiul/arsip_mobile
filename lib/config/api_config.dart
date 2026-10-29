import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class ApiConfig {
  static String _resolveDefaultBaseUrl() {
    try {
      if (Platform.isAndroid) {
        return 'http://192.168.1.22:8000/api/v1'; // Menggunakan IP Laptop agar bisa diakses dari HP fisik
      } else if (Platform.isIOS || Platform.isMacOS) {
        return 'http://127.0.0.1:8000/api/v1';
      }
    } catch (_) {}
    return 'http://192.168.1.22:8000/api/v1';
  }

  static String baseUrl = _resolveDefaultBaseUrl();

  static const int connectionTimeout = 30000; // 30 detik
  static const int receiveTimeout = 30000;

  // Header keys
  static const String headerAuth = 'Authorization';
  static const String headerUniqueId = 'x-uniqueid';
  static const String headerTimestamp = 'x-timestamp';
  static const String headerFilterCabang = 'x-filter-cabang';

  // Security Keys for System Access Token
  static const String userKey = 'b9c4e2a1f8d3b7c6e5a4f1d2e9c8b7a6';
  static const String userPasKey = 'd7a8f9e1b2c3d4e5f6a7b8c9d0e1f2a3';
  static const String userSecret = 'c3b4a5d6e7f8a9b0c1d2e3f4a5b6c7d8';

  /// Generate Basic Auth token for /auth/token endpoint
  static String getBasicToken() {
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final key = '$userKey#$dateStr#Key';
    final pasKey = '$userPasKey#$dateStr#PassKey';
    final secret = '$userSecret#$dateStr#SecretKey';

    final hmac1 = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(key)).toString();
    final hmac2 = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(pasKey)).toString();
    final credentials = base64Encode(utf8.encode('$hmac1:$hmac2'));
    return 'Basic $credentials';
  }

  // Global State for ApiClient
  static int? selectedBranchId;

  // Master Endpoints
  static const String endpointBranchGet =
      '/master/organisasi/branches/get-data';

  // Auth Endpoints
  static const String endpointToken = '/auth/token';
  static const String endpointLogin = '/auth/login';
  static const String endpointResetPassword = '/auth/reset-password';

  // Dashboard Endpoints
  static const String endpointDashboardSummary = '/dashboard/summary';
  static const String endpointOutgoingDashboardStats =
      '/correspondence/outgoing-letter-dashboard-stats';
  static const String endpointArsipDashboardStats =
      '/arsip-dokumen/dashboard/summary';
  static const String endpointBukuTamuMonitoring =
      '/buku-tamu/visit-monitoring';

  // Correspondence / Approval Endpoints
  static const String endpointOutgoingApprovalData =
      '/correspondence/outgoing-letter-approval-data';
  static const String endpointOutgoingDetail =
      '/correspondence/outgoing-letter-detail';
  static const String endpointOutgoingApprove =
      '/correspondence/outgoing-letter-approve';
  static const String endpointOutgoingReject =
      '/correspondence/outgoing-letter-reject';
  static const String endpointOutgoingFileDownload =
      '/correspondence/outgoing-file-download';

  // Disposition Endpoints
  static const String endpointDispositionData =
      '/correspondence/letter-disposition-data';
  static const String endpointDispositionProcess =
      '/correspondence/letter-disposition-process';
  static const String endpointDispositionComplete =
      '/correspondence/letter-disposition-complete';

  // Archive Loan Endpoints
  static const String endpointArchiveLoanGet = '/arsip-dokumen/loan/get';
  static const String endpointArchiveLoanApprove =
      '/arsip-dokumen/loan/approve';

  // Document Version Endpoints
  static const String endpointDocumentVersionGet = '/arsip-dokumen/version/get';
  static const String endpointDocumentVersionApprove =
      '/arsip-dokumen/version/approve';

  // Guest Book / Visit Endpoints
  static const String endpointVisitData = '/buku-tamu/visit-data';
  static const String endpointVisitApproval = '/buku-tamu/visit-approval';

  // Destruction Proposal Endpoints
  static const String endpointDestructionGet = '/arsip-dokumen/destruction/get';
  static const String endpointDestructionReview =
      '/arsip-dokumen/destruction/review';

  // Notification Endpoints
  static const String endpointNotificationGet = '/notification';
  static const String endpointNotificationMarkRead = '/notification/mark-read';

  static void setBaseUrl(String newUrl) {
    String formatted = newUrl.trim();
    if (formatted.isEmpty) return;

    // Fix typos like http:/192.168.1.50 -> http://192.168.1.50
    formatted = formatted.replaceAll(RegExp(r'^http:/+(?!/)'), 'http://');
    formatted = formatted.replaceAll(RegExp(r'^https:/+(?!/)'), 'https://');

    // Add protocol if missing
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'http://$formatted';
    }

    // Strip trailing slashes
    formatted = formatted.replaceAll(RegExp(r'/+$'), '');

    // Ensure /api/v1 suffix exists if no API version path is present
    if (!formatted.endsWith('/api/v1') && !formatted.contains('/api/v')) {
      formatted = '$formatted/api/v1';
    }

    baseUrl = formatted;
  }
}
