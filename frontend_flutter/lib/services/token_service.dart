import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const _tokenKey = 'token';

  // ================= SAVE TOKEN =================
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // ================= GET TOKEN =================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ================= GET USER ID (✅ REQUIRED) =================
  static Future<String?> getUserId() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));

      final data = jsonDecode(payload);
      return data['id']; // 👈 backend uses `id`
    } catch (_) {
      return null;
    }
  }

  // ================= GET USER ROLE (OPTIONAL) =================
  static Future<String?> getRole() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final parts = token.split('.');
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(payload);
      return data['role'];
    } catch (_) {
      return null;
    }
  }

  // ================= CLEAR =================
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
