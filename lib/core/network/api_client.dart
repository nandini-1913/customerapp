import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Minimal HTTP client for the FastAPI envelope `{ success, data, error }`.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? queryParameters,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPrefix}$path')
        .replace(queryParameters: queryParameters);
    final response = await _client.get(uri).timeout(timeout);
    return _decodeEnvelope(response);
  }

  Map<String, dynamic> _decodeEnvelope(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'HTTP ${response.statusCode}',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Invalid JSON envelope');
    }

    final success = decoded['success'] == true;
    if (!success) {
      throw ApiException(
        decoded['error']?.toString() ?? 'API request failed',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() => 'ApiException($message)';
}
