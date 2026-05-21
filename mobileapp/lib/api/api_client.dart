import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobileapp/api/token_storage.dart';

class ApiException implements Exception {
  ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() {
    return 'ApiException($statusCode): $message';
  }
}

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required TokenStorage tokenStorage,
    http.Client? client,
  })  : _tokenStorage = tokenStorage,
        _client = client ?? http.Client();

  final String baseUrl;
  final TokenStorage _tokenStorage;
  final http.Client _client;

  Future<Map<String, dynamic>> getJson(String path) {
    return _send('GET', path);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) {
    return _send('PUT', path, body: body);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _buildHeaders();
    final encoded = body == null ? null : jsonEncode(body);

    final response = switch (method) {
      'GET' => await _client.get(uri, headers: headers),
      'POST' => await _client.post(
        uri,
        headers: headers,
        body: encoded,
      ),
      'PUT' => await _client.put(
        uri,
        headers: headers,
        body: encoded,
      ),
      _ => throw ApiException(message: 'Unsupported method $method'),
    };

    return _decodeResponse(response);
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final token = await _tokenStorage.read();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final body = response.body.trim();
    final jsonBody = body.isEmpty
      ? const <String, dynamic>{}
      : jsonDecode(body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = jsonBody is Map
          ? (jsonBody['detail'] as String? ?? 'Request failed')
          : 'Request failed';
      throw ApiException(
        message: message,
        statusCode: response.statusCode,
      );
    }

    if (jsonBody is Map<String, dynamic>) {
      return jsonBody;
    }

    throw ApiException(message: 'Unexpected response format');
  }
}
