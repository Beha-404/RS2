import 'dart:convert';
import 'package:desktop/config/config.dart';
import 'package:desktop/models/pc.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:desktop/utils/auth_helper.dart';
import 'package:desktop/utils/error_parser.dart';
import 'package:http/http.dart' as http;

class PcService {
  final UserProvider? userProvider;
  
  const PcService({this.userProvider});

  Map<String, String> _getHeaders() => AuthHelper.getAuthHeaders(userProvider);

  Future<List<PC>> get() async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/get');
    final response = await http.get(uri, headers: _getHeaders());
    if (response.statusCode == 200) {
      final Map<String, dynamic> pagedResult = jsonDecode(response.body);
      final List<dynamic> items = pagedResult['items'] ?? [];
      return items.map((e) => PC.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load pcs');
    }
  }

  Future<PC?> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/get/$id');
    final response = await http.get(uri, headers: _getHeaders());
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PC.fromJson(json);
    } else {
      throw Exception('Failed to load pc');
    }
  }

  Future<bool> insert(PC request) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/insert');
    final response = await http.post(
      uri,
      headers: {..._getHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(ErrorParser.parseHttpError(response));
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/hide/$id');
    final response = await http.put(uri, headers: _getHeaders());
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete pc');
    }
  }

  Future<bool> update(PC request) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/update/${request.id}');
    final response = await http.put(
      uri,
      headers: {..._getHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(ErrorParser.parseHttpError(response));
    }
  }

  // State Machine Methods
  Future<List<String>> getAllowedActions(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/allowedActions/$id');
    final response = await http.get(uri, headers: _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> actions = jsonDecode(response.body);
      return actions.map((e) => e.toString()).toList();
    } else {
      return [];
    }
  }

  Future<bool> activate(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/activate/$id');
    final response = await http.put(uri, headers: _getHeaders());
    return response.statusCode == 200;
  }

  Future<bool> edit(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/edit/$id');
    final response = await http.put(uri, headers: _getHeaders());
    return response.statusCode == 200;
  }

  Future<bool> hide(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/pc/hide/$id');
    final response = await http.put(uri, headers: _getHeaders());
    return response.statusCode == 200;
  }
}
