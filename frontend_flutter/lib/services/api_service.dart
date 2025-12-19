import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<http.Response> get(String endpoint, String token) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final res = await http.get(uri, headers: _headers(token));

    _log('GET', uri.toString(), res);

    return res;
  }

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

  static Future<http.Response> delete(
    String endpoint,
    String token,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final res = await http.delete(uri, headers: _headers(token));

    _log('DELETE', uri.toString(), res);

    return res;
  }

  static void _log(String method, String url, http.Response res) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('$method $url');
    print('STATUS: ${res.statusCode}');
    print('BODY: ${res.body}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}
