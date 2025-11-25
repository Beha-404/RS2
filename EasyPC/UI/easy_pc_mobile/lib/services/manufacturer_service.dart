import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/manufacturer.dart';
import 'package:http/http.dart' as http;

class ManufacturerService {
  const ManufacturerService();

  Future<List<Manufacturer>> getAll() async {
    final uri = Uri.parse('$apiBaseUrl/api/manufacturer/get');
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      
      final List<dynamic> items = json['items'];
      return items.map((e) => Manufacturer.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load manufacturers');
    }
  }

  Future<List<Manufacturer>> getByComponentType(String componentType) async {
    final queryParams = {'ComponentType': componentType};
    
    final uri = Uri.parse('$apiBaseUrl/api/manufacturer/get')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
    
      final List<dynamic> items = json['items'];
      return items.map((e) => Manufacturer.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load manufacturers for $componentType');
    }
  }

  Future<Manufacturer?> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/manufacturer/get/$id');
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Manufacturer.fromJson(json);
    } else {
      return null;
    }
  }

  Future<Manufacturer?> insert(Manufacturer manufacturer) async {
    final uri = Uri.parse('$apiBaseUrl/api/manufacturer/insert');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(manufacturer.toJson()),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Manufacturer.fromJson(json);
    } else {
      throw Exception('Failed to create manufacturer');
    }
  }

  Future<Manufacturer?> update(int id, Manufacturer manufacturer) async {
    final uri = Uri.parse('$apiBaseUrl/api/manufacturer/update/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(manufacturer.toJson()),
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Manufacturer.fromJson(json);
    } else {
      throw Exception('Failed to update manufacturer');
    }
  }
}