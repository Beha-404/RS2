import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/motherboard.dart';
import 'package:http/http.dart' as http;

class MotherboardService {
  const MotherboardService();

  Future<List<MotherBoard>> getAll() async {
    final uri = Uri.parse('$apiBaseUrl/api/motherboard/get');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> pagedResult = jsonDecode(response.body);
      final List<dynamic> items = pagedResult['items'] ?? [];
      return items.map((e) => MotherBoard.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load motherboards');
    }
  }

  Future<bool> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/motherboard/get/$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> insert(MotherBoard request) async {
    final uri = Uri.parse('$apiBaseUrl/api/motherboard/insert');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create motherboard');
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/motherboard/hide/$id');
    final response = await http.put(uri);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> update(MotherBoard request) async {
    final uri = Uri.parse('$apiBaseUrl/api/motherboard/update/${request.id}');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update motherboard');
    }
  }
}
