import 'dart:convert';
import 'package:desktop/config/config.dart';
import 'package:desktop/models/manufacturer.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:desktop/utils/auth_helper.dart';
import 'package:desktop/utils/error_parser.dart';
import 'package:http/http.dart' as http;

class ManufacturerService {
  final UserProvider? userProvider;
  
  const ManufacturerService({this.userProvider});

  Map<String, String> _getHeaders() => AuthHelper.getAuthHeaders(userProvider);

  Future<List<Manufacturer>> get() async {
    final uri = Uri.parse('$apiBaseUrl/api/manufacturer/get');
    final response = await http.get(uri, headers: _getHeaders());
    if (response.statusCode == 200) {
      final Map<String, dynamic> pagedResult = jsonDecode(response.body);
      final List<dynamic> items = pagedResult['items'] ?? [];
      return items.map((e) => Manufacturer.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load manufacturers');
    }
  }

  Future<List<Manufacturer>> getByComponentType(String componentType) async {
    final queryParams = {'ComponentType': componentType};

    final uri = Uri.parse('$apiBaseUrl/api/manufacturer/get')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> pagedResult = jsonDecode(response.body);
      final List<dynamic> items = pagedResult['items'] ?? [];
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
      throw Exception('Failed to load manufacturer');
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/manufacturer/hide/$id');
    final response = await http.put(uri);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> insert(Manufacturer request) async {
    final uri = Uri.parse('$apiBaseUrl/api/manufacturer/insert');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(ErrorParser.parseHttpError(response));
    }
  }

  Future<bool> update(Manufacturer request) async {
    final uri = Uri.parse('$apiBaseUrl/api/manufacturer/update/${request.id}');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(ErrorParser.parseHttpError(response));
    }
  }
}
