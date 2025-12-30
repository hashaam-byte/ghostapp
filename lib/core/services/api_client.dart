import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static void init() {
    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if exists
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 - token expired
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry original request
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // GET request
  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  static Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  static Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  static Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  static Future<Response> patch(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.patch(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Multipart upload (for images, voice)
  static Future<Response> uploadFile(
    String path,
    String filePath,
    String fieldName, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?data,
      });
      return await _dio.post(path, data: formData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Token refresh
  static Future<bool> _refreshToken() async {
    try {
      final response = await _dio.post(ApiConfig.refresh);
      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        await StorageService.saveToken(newToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Retry request
  static Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Error handler
  static ApiException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException('Connection timeout. Check your internet.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data['message'] ?? 'Unknown error';
          return ApiException(message, statusCode: statusCode);
        case DioExceptionType.cancel:
          return ApiException('Request cancelled');
        default:
          return ApiException('Network error. Please try again.');
      }
    }
    return ApiException('Unexpected error occurred');
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}