import 'dart:convert';
import 'package:desktop/config/config.dart';
import 'package:desktop/models/motherboard.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:desktop/utils/auth_helper.dart';
import 'package:desktop/utils/error_parser.dart';
import 'package:http/http.dart' as http;

class MotherboardService {
  final UserProvider? userProvider;
  
  const MotherboardService({this.userProvider});

  Future<List<MotherBoard>> get() async {
    final uri = Uri.parse('$apiBaseUrl/api/motherboard/get');
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
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
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
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
      headers: {...AuthHelper.getAuthHeaders(userProvider), 'Content-Type': 'application/json'},
      body: jsonEncode(request.toMap()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(ErrorParser.parseHttpError(response));
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/motherboard/hide/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
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
      headers: {...AuthHelper.getAuthHeaders(userProvider), 'Content-Type': 'application/json'},
      body: jsonEncode(request.toMap()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(ErrorParser.parseHttpError(response));
    }
  }

  Future<List<String>> getAllowedActions(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/motherboard/allowedActions/$id');
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    if (response.statusCode == 200) {
      final List<dynamic> actions = jsonDecode(response.body);
      return actions.map((e) => e.toString()).toList();
    } else {
      return [];
    }
  }

  Future<bool> activate(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/motherboard/activate/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }

  Future<bool> hide(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/motherboard/hide/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }

  Future<bool> edit(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/motherboard/edit/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }
}
