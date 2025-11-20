import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/power_supply.dart';
import 'package:http/http.dart' as http;

class PowerSupplyService {
  const PowerSupplyService();

  Future<List<PowerSupply>> getAll() async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/get');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> pagedResult = jsonDecode(response.body);
      final List<dynamic> items = pagedResult['items'] ?? [];
      return items.map((e) => PowerSupply.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load power supplies');
    }
  }

  Future<PowerSupply?> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/get/$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PowerSupply.fromJson(json);
    } else {
      throw Exception('Failed to load power supply');
    }
  }

  Future<bool> insert(PowerSupply request) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/insert');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create power supply');
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/hide/$id');
    final response = await http.put(uri);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> update(PowerSupply request) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/update/${request.id}');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update power supply');
    }
  }
}
