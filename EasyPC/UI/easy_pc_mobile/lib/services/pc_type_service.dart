import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/pc_type.dart';
import 'package:http/http.dart' as http;

class PcTypeService {
  const PcTypeService();

  Future<List<PcType>> get() async {
    final uri = Uri.parse('$apiBaseUrl/api/pctype/get');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> items = jsonDecode(response.body);
      return items.map((e) => PcType.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load PC types');
    }
  }

  Future<PcType?> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/pctype/get/$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PcType.fromJson(json);
    } else {
      throw Exception('Failed to load PC type');
    }
  }
}
