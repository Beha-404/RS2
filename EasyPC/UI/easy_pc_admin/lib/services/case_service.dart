import 'dart:convert';
import 'package:desktop/config/config.dart';
import 'package:desktop/models/case.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:desktop/utils/auth_helper.dart';
import 'package:desktop/utils/error_parser.dart';
import 'package:http/http.dart' as http;

class CaseService {
  final UserProvider? userProvider;
  
  const CaseService({this.userProvider});

  Future<List<Case>> get() async {
    final uri  = Uri.parse('$apiBaseUrl/api/case/get');
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
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
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Case.fromJson(json);
    } else {
      throw Exception('Failed to load case');
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/case/hide/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
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
      headers: {...AuthHelper.getAuthHeaders(userProvider), 'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(ErrorParser.parseHttpError(response));
    }
  }

  Future<bool> update(Case request) async {
    final uri = Uri.parse('$apiBaseUrl/api/case/update/${request.id}');
    final response = await http.put(
      uri,
      headers: {...AuthHelper.getAuthHeaders(userProvider), 'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(ErrorParser.parseHttpError(response));
    }
  }

  Future<List<String>> getAllowedActions(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/case/allowedActions/$id');
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    if (response.statusCode == 200) {
      final List<dynamic> actions = jsonDecode(response.body);
      return actions.map((e) => e.toString()).toList();
    } else {
      return [];
    }
  }

  Future<bool> activate(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/case/activate/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }

  Future<bool> hide(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/case/hide/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }

  Future<bool> edit(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/case/edit/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }
}
 