import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../constants/api_constants.dart';

class ApiService {
  // ================= BASIC HEADERS =================
  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ================= GET =================
  static Future<http.Response> get(String endpoint, String token) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final res = await http.get(uri, headers: _headers(token));
    _log('GET', uri.toString(), res);
    return res;
  }

  // ================= POST =================
  static Future<http.Response> post(
    String endpoint,
    String token,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    );
    _log('POST', uri.toString(), res);
    return res;
  }

  // ================= PUT =================
  static Future<http.Response> put(
    String endpoint,
    String token,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final res = await http.put(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    );
    _log('PUT', uri.toString(), res);
    return res;
  }

  // ================= DELETE =================
  static Future<http.Response> delete(
    String endpoint,
    String token,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final res = await http.delete(uri, headers: _headers(token));
    _log('DELETE', uri.toString(), res);
    return res;
  }

  // ================= MULTIPART PUT (NEW) =================
  static Future<http.Response> multipartPut(
    String endpoint,
    String token,
    Map<String, String> fields, {
    List<File> files = const [],
    String fileField = 'images',
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final request = http.MultipartRequest('PUT', uri);

    // Auth header ONLY (no JSON content-type)
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Add fields
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add files
    for (final file in files) {
      final multipartFile = await http.MultipartFile.fromPath(
        fileField,
        file.path,
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _log('MULTIPART PUT', uri.toString(), response);

    return response;
  }

  // ================= MULTIPART POST (NEW) =================
  static Future<http.Response> multipartPost(
    String endpoint,
    String token,
    Map<String, String> fields, {
    List<File> files = const [],
    String fileField = 'images',
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Add text fields
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add image files WITH MIME TYPE
    for (final file in files) {
      final extension = file.path.split('.').last.toLowerCase();

      final mimeType = switch (extension) {
        'jpg' || 'jpeg' => 'jpeg',
        'png' => 'png',
        'webp' => 'webp',
        _ => null,
      };

      if (mimeType == null) continue;

      final multipartFile = await http.MultipartFile.fromPath(
        fileField,
        file.path,
        contentType: MediaType('image', mimeType), // 🔑 FIX
      );

      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _log('MULTIPART POST', uri.toString(), response);

    return response;
  }

  // ================= LOGGER =================
  static void _log(String method, String url, http.Response res) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('$method $url');
    print('STATUS: ${res.statusCode}');
    print('BODY: ${res.body}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}
