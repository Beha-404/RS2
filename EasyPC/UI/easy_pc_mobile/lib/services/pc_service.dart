import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/paged_result.dart';
import 'package:easy_pc/models/pc.dart';
import 'package:http/http.dart' as http;

class PcService {
  const PcService();

  Future<PagedResult<PC>> getAll({
    int page = 1, 
    int pageSize = 4,
    Map<String, dynamic>? filters,
    Map<String, String>? headers,
  }) async {
    final queryParams = {
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

     if (filters != null) {
    if (filters['pcTypeId'] != null) {
      queryParams['PcTypeId'] = filters['pcTypeId'].toString();
    }
    if (filters['cpuManufacturerId'] != null) {
      queryParams['ProcessorManufacturerId'] = filters['cpuManufacturerId'].toString();
    }
    if (filters['gpuManufacturerId'] != null) {
      queryParams['GraphicsCardManufacturerId'] = filters['gpuManufacturerId'].toString();
    }
    if (filters['ramManufacturerId'] != null) {
      queryParams['RamManufacturerId'] = filters['ramManufacturerId'].toString();
    }
    if (filters['motherboardManufacturerId'] != null) {
      queryParams['MotherBoardManufacturerId'] = filters['motherboardManufacturerId'].toString();
    }
    if (filters['psuManufacturerId'] != null) {
      queryParams['PowerSupplyManufacturerId'] = filters['psuManufacturerId'].toString();
    }
    if (filters['caseManufacturerId'] != null) {
      queryParams['CaseManufacturerId'] = filters['caseManufacturerId'].toString();
    }
    if (filters['minPrice'] != null) {
      queryParams['MinPrice'] = filters['minPrice'].toString();
    }
    if (filters['maxPrice'] != null) {
      queryParams['MaxPrice'] = filters['maxPrice'].toString();
    }
  }

    final uri = Uri.parse(
      '$apiBaseUrl/api/pc/get',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PagedResult<PC>.fromJson(
        json,
        (item) => PC.fromJson(item),
      );
    } else {
      throw Exception('Failed to load PCs: ${response.statusCode}');
    }
  }

  Future<PC?> getById(int id, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/get/$id');
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PC.fromJson(json);
    } else {
      throw Exception('Failed to load pc');
    }
  }

  Future<bool> insert(PC request, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/insert');
    final response = await http.post(
      uri,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create pc');
    }
  }

  Future<bool> deleteById(int id, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/hide/$id');
    final response = await http.put(uri, headers: headers);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete pc');
    }
  }

  Future<bool> update(PC request, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/update/${request.id}');
    final response = await http.put(
      uri,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update pc');
    }
  }

  Future<List<PC>> getRecommendations(int pcId, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/$pcId/recommend');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((item) => PC.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load recommendations: ${response.statusCode}');
    }
  }
}
