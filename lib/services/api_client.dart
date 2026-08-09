import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';

/// API client for OpenWrt setup endpoints
class OpenWrtApiClient {
  final String baseUrl;
  final String? setupToken;
  final HttpClient _httpClient;
  final FlutterSecureStorage _secureStorage;

  OpenWrtApiClient({
    required this.baseUrl,
    this.setupToken,
    FlutterSecureStorage? secureStorage,
  })  : _httpClient = HttpClient(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }

  /// Get device information
  Future<DeviceInfo> getInfo() async {
    final response = await _get('/api/v1/info');
    return DeviceInfo.fromJson(response);
  }

  /// Get device status
  Future<SetupStatus> getStatus() async {
    final response = await _get('/api/v1/status');
    return SetupStatus.fromJson(response);
  }

  /// Configure WiFi access point
  Future<bool> configureWifi(WifiConfig config) async {
    final response = await _post('/api/v1/wifi', config.toJson());
    return response['success'] ?? false;
  }

  /// Configure station/uplink WiFi
  Future<bool> configureStation(StationConfig config) async {
    final response = await _post('/api/v1/station', config.toJson());
    return response['success'] ?? false;
  }

  /// Configure admin settings
  Future<bool> configureAdmin(AdminConfig config) async {
    final response = await _post('/api/v1/admin', config.toJson());
    return response['success'] ?? false;
  }

  /// Apply configuration and reboot
  Future<bool> applyConfiguration() async {
    final response = await _post('/api/v1/apply', {});
    return response['success'] ?? false;
  }

  /// Generic GET request
  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = await _httpClient.getUrl(uri);
      request.headers.set('Accept', 'application/json');
      
      if (setupToken != null && setupToken!.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $setupToken');
      }

      final response = await request.close();
      
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw ApiError(
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
          statusCode: 401,
        );
      } else {
        final body = await response.transform(utf8.decoder).join();
        final error = jsonDecode(body);
        throw ApiError(
          message: error['message'] ?? 'Request failed',
          code: error['code'],
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw ApiError(
        message: 'Network error: ${e.message}',
        code: 'NETWORK_ERROR',
      );
    } on HttpException catch (e) {
      throw ApiError(
        message: 'HTTP error: ${e.message}',
        code: 'HTTP_ERROR',
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(
        message: 'Unknown error: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = await _httpClient.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      
      if (setupToken != null && setupToken!.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $setupToken');
      }

      request.write(jsonEncode(data));

      final response = await request.close();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw ApiError(
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
          statusCode: 401,
        );
      } else {
        final body = await response.transform(utf8.decoder).join();
        final error = jsonDecode(body);
        throw ApiError(
          message: error['message'] ?? 'Request failed',
          code: error['code'],
          statusCode: response.statusCode,
          details: error['details'],
        );
      }
    } on SocketException catch (e) {
      throw ApiError(
        message: 'Network error: ${e.message}',
        code: 'NETWORK_ERROR',
      );
    } on HttpException catch (e) {
      throw ApiError(
        message: 'HTTP error: ${e.message}',
        code: 'HTTP_ERROR',
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(
        message: 'Unknown error: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Store setup token securely
  Future<void> storeToken(String deviceId, String token) async {
    await _secureStorage.write(key: 'token_$deviceId', value: token);
  }

  /// Retrieve stored token
  Future<String?> getToken(String deviceId) async {
    return await _secureStorage.read(key: 'token_$deviceId');
  }

  /// Delete stored token
  Future<void> deleteToken(String deviceId) async {
    await _secureStorage.delete(key: 'token_$deviceId');
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}
