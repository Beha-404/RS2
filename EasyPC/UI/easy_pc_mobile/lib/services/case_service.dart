import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/case.dart';
import 'package:http/http.dart' as http;

class CaseService {
  const CaseService();

  Future<List<Case>> getAll() async {
    final uri  = Uri.parse('$apiBaseUrl/api/case/get');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> pagedResult = jsonDecode(response.body);
      final List<dynamic> items = pagedResult['items'] ?? [];
      return items.map((e) => Case.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load cases');
    }
  }

  Future<Case?> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/case/get/$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Case.fromJson(json);
    } else {
      throw Exception('Failed to load case');
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/case/hide/$id');
    final response = await http.put(uri);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> insert(Case request) async {
    final uri = Uri.parse('$apiBaseUrl/api/case/insert');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create case');
    }
  }

  Future<bool> update(Case request) async {
    final uri = Uri.parse('$apiBaseUrl/api/case/update/${request.id}');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update case');
    }
  }
} 