import 'dart:convert';

import 'package:http/http.dart' as http;

/// Centraliza todas las llamadas a tu API de vocab-trainer.
class ApiService {
  // IMPORTANTE: reemplaza esta IP por la de TU computadora.
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

  /// Devuelve la lista de tarjetas pendientes de repaso hoy.
  static Future<List<Map<String, dynamic>>> getDueCards(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cards/due'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception('Error al obtener las tarjetas pendientes');
  }

  /// Devuelve las tarjetas agrupadas por verbo, para la pantalla de
  /// "Mi vocabulario". La forma: { "groups": [...], "ungrouped": [...] }
  static Future<Map<String, dynamic>> getGroupedCards(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cards/grouped'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Error al obtener el vocabulario');
  }

  /// Envía una calificación (0-5) de qué tan bien recordaste una tarjeta.
  static Future<void> submitReview(
    String token,
    int cardId,
    int quality,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cards/$cardId/review'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'quality': quality}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['error'] ?? 'Error al enviar el repaso');
    }
  }

  /// Importa el paquete de vocabulario inicial (verbos irregulares comunes).
  /// Devuelve cuántas tarjetas NUEVAS se agregaron.
  static Future<int> importSeedPack(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cards/seed'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['imported'] as int;
    }

    throw Exception('Error al importar el vocabulario inicial');
  }
}
