import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/graphics_card.dart';
import 'package:http/http.dart' as http;

class GraphicsCardService {
  const GraphicsCardService();

  Future<List<GraphicsCard>> getAll() async {
    final uri = Uri.parse('$apiBaseUrl/api/graphicscard/get');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> pagedResult = jsonDecode(response.body);
      final List<dynamic> items = pagedResult['items'] ?? [];
      return items.map((e) => GraphicsCard.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load graphicscards');
    }
  }

  Future<GraphicsCard?> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/graphicscard/get/$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return GraphicsCard.fromJson(json);
    } else {
      throw Exception('Failed to load graphics card');
    }
  }

  Future<bool> insert(GraphicsCard request) async {
    final uri = Uri.parse('$apiBaseUrl/api/graphicscard/insert');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create graphics card');
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/graphicscard/hide/$id');
    final response = await http.put(uri);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> update(GraphicsCard request) async {
    final uri = Uri.parse('$apiBaseUrl/api/graphicscard/update/${request.id}');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update graphics card');
    }
  }
}
