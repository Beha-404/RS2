import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/processor.dart';
import 'package:http/http.dart' as http;

class ProcessorService {
  const ProcessorService();

  Future<List<Processor>> getAll() async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/get');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> pagedResult = jsonDecode(response.body);
      final List<dynamic> items = pagedResult['items'] ?? [];
      return items.map((e) => Processor.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load processors');
    }
  }

  Future<Processor?> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/get/$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Processor.fromJson(json);
    } else {
      throw Exception('Failed to load processor');
    }
  }

  Future<bool> insert(Processor request) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/insert');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create processor');
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/hide/$id');
    final response = await http.put(uri);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> update(Processor request) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/update/${request.id}');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update processor');
    }
  }
}
