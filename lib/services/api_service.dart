import 'dart:convert';

import 'package:http/http.dart' as http;

/// Centraliza todas las llamadas a tu API de vocab-trainer.
///
/// Mismo principio que TaskManager/CardManager en tu backend: en vez de
/// hacer llamadas HTTP sueltas desde cada pantalla, las juntamos aquí en
/// un solo lugar.
class ApiService {
  // IMPORTANTE: reemplaza esta IP por la de TU computadora (la misma que
  // usaste para probar http://TU_IP:5000/ desde el navegador del celular).
  // Debe ser la IP local (192.168.x.x), no 127.0.0.1 ni localhost.
  static const String baseUrl = 'http://192.168.1.43:5000';

  static Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data['token'] as String;
    }

    throw Exception(data['error'] ?? 'Error al iniciar sesión');
  }

  static Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['error'] ?? 'Error al registrarse');
    }
  }
}
