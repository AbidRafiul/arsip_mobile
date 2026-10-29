import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ));
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Dynamic Base URL check
          options.baseUrl = ApiConfig.baseUrl;

          final accessToken = await SecureStorageService.getAccessToken();
          final jwtCredential = await SecureStorageService.getJwtCredential();
          final userData = await SecureStorageService.getUserData();
          final username = userData['username'];

          // Only set Bearer token if Authorization header is not already set (e.g. Basic token for /auth/token)
          if (!options.headers.containsKey(ApiConfig.headerAuth)) {
            final tokenToUse = (jwtCredential != null && jwtCredential.isNotEmpty)
                ? jwtCredential
                : accessToken;

            if (tokenToUse != null && tokenToUse.isNotEmpty) {
              options.headers[ApiConfig.headerAuth] = 'Bearer $tokenToUse';
            }
          }

          if (username != null && username.isNotEmpty) {
            options.headers[ApiConfig.headerUniqueId] = username;
          }

          options.headers[ApiConfig.headerTimestamp] = DateTime.now().toIso8601String();

          // Global Branch Switcher override (sama dengan Web: memuat cabang dan turunannya)
          if (ApiConfig.selectedBranchId != null) {
            options.headers[ApiConfig.headerFilterCabang] = ApiConfig.selectedBranchId.toString();
          } else {
            // Remove it if null so Superadmin can see all branches
            options.headers.remove(ApiConfig.headerFilterCabang);
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await dio.get(endpoint, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await dio.post(endpoint, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String endpoint, {dynamic data, Options? options}) async {
    return await dio.put(endpoint, data: data, options: options);
  }

  Future<Response> delete(String endpoint, {dynamic data, Options? options}) async {
    return await dio.delete(endpoint, data: data, options: options);
  }
}
