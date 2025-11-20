import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/ram.dart';
import 'package:http/http.dart' as http;

class RamService {
  const RamService();

  Future<List<Ram>> getAll() async {
    final uri = Uri.parse('$apiBaseUrl/api/ram/get');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> pagedResult = jsonDecode(response.body);
      final List<dynamic> items = pagedResult['items'] ?? [];
      return items.map((e) => Ram.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load rams');
    }
  }

  Future<Ram?> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/ram/get/$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Ram.fromJson(json);
    } else {
      throw Exception('Failed to load ram');
    }
  }

  Future<bool> insert(Ram request) async {
    final uri = Uri.parse('$apiBaseUrl/api/ram/insert');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create ram');
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/ram/hide/$id');
    final response = await http.put(uri);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> update(Ram request) async {
    final uri = Uri.parse('$apiBaseUrl/api/ram/update/${request.id}');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update ram');
    }
  }
}
