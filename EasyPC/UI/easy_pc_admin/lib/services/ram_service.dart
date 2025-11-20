import 'dart:convert';
import 'package:desktop/config/config.dart';
import 'package:desktop/models/ram.dart';
import 'package:http/http.dart' as http;
import 'package:desktop/providers/user_provider.dart';
import 'package:desktop/utils/auth_helper.dart';

class RamService {
  final UserProvider? userProvider;
  const RamService({this.userProvider});

  Future<List<Ram>> get() async {
    final uri = Uri.parse('$apiBaseUrl/api/ram/get');
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
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
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
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
      headers: AuthHelper.getAuthHeaders(userProvider),
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
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
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
      headers: AuthHelper.getAuthHeaders(userProvider),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update ram');
    }
  }

  Future<List<String>> getAllowedActions(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/ram/allowedActions/$id');
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    if (response.statusCode == 200) {
      final List<dynamic> actions = jsonDecode(response.body);
      return actions.map((e) => e.toString()).toList();
    } else {
      return [];
    }
  }

  Future<bool> activate(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/ram/activate/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }

  Future<bool> hide(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/ram/hide/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }

  Future<bool> edit(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/ram/edit/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }
}
