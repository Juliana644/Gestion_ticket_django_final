import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Refresh automatique si token expiré
  Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');
    if (refresh == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('access_token', data['access']);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Requête GET avec gestion auto du 401
  Future<http.Response> get(String path) async {
    var response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        response = await http.get(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
        );
      }
    }
    return response;
  }

  // Requête POST avec gestion auto du 401
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    var response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        response = await http.post(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: jsonEncode(body),
        );
      }
    }
    return response;
  }

  // Requête PATCH avec gestion auto du 401
  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    var response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        response = await http.patch(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: jsonEncode(body),
        );
      }
    }
    return response;
  }
}
