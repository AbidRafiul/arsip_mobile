import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  String _formatDioError(DioException dioErr) {
    // 1. Cek error respon JSON dari backend (misal: "kata_sandi salah", "nama_pengguna tidak ditemukan")
    if (dioErr.response?.data != null && dioErr.response?.data is Map) {
      final rawMsg = dioErr.response?.data['message']?.toString() ?? '';
      if (rawMsg.contains('nama_pengguna tidak ditemukan') || rawMsg.contains('username tidak ditemukan')) {
        return 'Pengguna (Username) tidak ditemukan. Silakan periksa kembali nama pengguna Anda.';
      } else if (rawMsg.contains('kata_sandi salah') || rawMsg.contains('password salah')) {
        return 'Kata sandi yang Anda masukkan salah. Silakan periksa kembali kata sandi Anda.';
      } else if (rawMsg.contains('belum aktif')) {
        return 'Akun pengguna belum aktif. Silakan hubungi Administrator.';
      } else if (rawMsg.isNotEmpty) {
        return rawMsg;
      }
    }

    // 2. Timeout Error
    if (dioErr.type == DioExceptionType.connectionTimeout ||
        dioErr.type == DioExceptionType.sendTimeout ||
        dioErr.type == DioExceptionType.receiveTimeout) {
      return 'Tidak dapat terhubung ke server (Waktu Habis / Timeout). Pastikan server backend Express berjalan di PC.';
    }

    // 3. Network / Connection Error
    if (dioErr.type == DioExceptionType.connectionError ||
        dioErr.type == DioExceptionType.unknown) {
      final subMsg = dioErr.error?.toString() ?? dioErr.message ?? '';
      if (subMsg.contains('No route to host')) {
        return 'Tidak ada rute ke server (${ApiConfig.baseUrl}). Pastikan HP dan PC berada di satu jaringan yang sama.';
      } else if (subMsg.contains('Connection refused')) {
        return 'Koneksi ditolak (${ApiConfig.baseUrl}). Server backend Express belum dinyalakan di port 8000.';
      } else if (subMsg.contains('FormatSpecifier') || subMsg.contains('FormatException')) {
        return 'Format URL Server salah: "${ApiConfig.baseUrl}". Contoh: http://localhost:8000/api/v1';
      }
      return 'Tidak dapat terhubung ke server (${ApiConfig.baseUrl}). Periksa jaringan atau URL server Anda.';
    }

    final code = dioErr.response?.statusCode;
    if (code == 400 || code == 401 || code == 422) {
      return 'Nama pengguna atau kata sandi yang Anda masukkan tidak sesuai.';
    } else if (code == 404) {
      return 'Pengguna atau endpoint tidak ditemukan di server (404).';
    } else if (code == 500) {
      return 'Terjadi kesalahan internal pada server backend (500).';
    }

    return 'Tidak dapat terhubung ke server. Periksa kembali koneksi jaringan dan server Anda.';
  }

  Future<String?> fetchAccessToken() async {
    try {
      final basicToken = ApiConfig.getBasicToken();
      final response = await _apiClient.get(
        ApiConfig.endpointToken,
        options: Options(
          headers: {
            ApiConfig.headerAuth: basicToken,
          },
        ),
      );
      debugPrint("Fetch Token Status: ${response.statusCode}, Data: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['data']?['access_token'] ?? response.data['access_token'];
        if (token != null) {
          await SecureStorageService.saveAccessToken(token);
          return token;
        }
      }
    } on DioException catch (dioErr) {
      debugPrint("Fetch Token DioException: ${dioErr.type}, ${dioErr.message}, error: ${dioErr.error}");
      throw Exception(_formatDioError(dioErr));
    } catch (e) {
      debugPrint("Fetch Token Error: $e");
      if (e is Exception) rethrow;
    }
    return null;
  }

  Future<UserModel> login(String username, String password) async {
    try {
      debugPrint("=== START LOGIN ===");
      debugPrint("URL: ${ApiConfig.baseUrl}${ApiConfig.endpointLogin}");
      debugPrint("Username: $username");

      // 1. Ambil access token jika belum ada
      await fetchAccessToken();

      // 2. Kirim request login
      final response = await _apiClient.post(
        ApiConfig.endpointLogin,
        data: {
          'nama_pengguna': username,
          'kata_sandi': password,
        },
      );

      debugPrint("Login Response Status: ${response.statusCode}");
      debugPrint("Login Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        final statusVal = responseData['status'];

        if (statusVal == '00' || statusVal == 200 || statusVal == 'success' || statusVal == true) {
          final credential = responseData['credential'] ?? '';
          final rawUserMap = responseData['data'];
          final Map<String, dynamic> userMap = (rawUserMap is Map)
              ? Map<String, dynamic>.from(rawUserMap)
              : {};

          final user = UserModel.fromJson(userMap);

          // Simpan ke SecureStorage
          await SecureStorageService.saveJwtCredential(credential);
          await SecureStorageService.saveUserData(
            userId: user.userId,
            username: user.username,
            fullName: user.fullName,
            role: user.role,
            branchId: user.branchId,
          );

          debugPrint("=== LOGIN SUCCESSFUL for ${user.fullName} ===");
          return user;
        } else {
          final msg = responseData['message'] ?? 'Login gagal. Periksa kembali username dan kata sandi Anda.';
          debugPrint("Login rejected by backend: $msg");
          throw Exception(msg);
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Terjadi kesalahan sistem saat login');
      }
    } on DioException catch (dioErr) {
      debugPrint("DioException during login: ${dioErr.type}, ${dioErr.message}, Response: ${dioErr.response?.data}");
      throw Exception(_formatDioError(dioErr));
    } catch (e, stack) {
      debugPrint("General Exception during login: $e\n$stack");
      rethrow;
    }
  }

  Future<void> logout() async {
    await SecureStorageService.clearAll();
  }

  Future<void> changePassword(String username, String oldPassword, String newPassword) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.endpointResetPassword,
        data: {
          'nama_pengguna': username,
          'old_kata_sandi': oldPassword,
          'new_kata_sandi': newPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && (data['status'] == '00' || data['status'] == 200 || data['status'] == 'success' || data['status'] == true)) {
          return; // Berhasil
        } else {
          final msg = data?['message'] ?? 'Gagal mengubah password.';
          throw Exception(msg);
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Terjadi kesalahan sistem saat mengubah password');
      }
    } on DioException catch (dioErr) {
      if (dioErr.response?.data != null && dioErr.response?.data is Map) {
        final rawMsg = dioErr.response?.data['message']?.toString() ?? '';
        if (rawMsg.isNotEmpty) {
           throw Exception(rawMsg);
        }
      }
      throw Exception(_formatDioError(dioErr));
    } catch (e) {
      rethrow;
    }
  }
}
