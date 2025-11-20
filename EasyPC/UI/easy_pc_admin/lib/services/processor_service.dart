import 'dart:convert';
import 'package:desktop/config/config.dart';
import 'package:desktop/models/processor.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:desktop/utils/auth_helper.dart';
import 'package:http/http.dart' as http;

class ProcessorService {
  final UserProvider? userProvider;
  
  const ProcessorService({this.userProvider});

  Map<String, String> _getHeaders() => AuthHelper.getAuthHeaders(userProvider);

  Future<List<Processor>> get() async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/get');
    final response = await http.get(uri, headers: _getHeaders());
    if (response.statusCode == 200) {
      final Map<String, dynamic> pagedResult = jsonDecode(response.body);
      final List<dynamic> items = pagedResult['items'] ?? [];
      return items.map((e) => Processor.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load processors');
    }
  }

  Future<Processor?> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/get/$id');
    final response = await http.get(uri, headers: _getHeaders());
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Processor.fromJson(json);
    } else {
      throw Exception('Failed to load processor');
    }
  }

  Future<bool> insert(Processor request) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/insert');
    final response = await http.post(
      uri,
      headers: _getHeaders(),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create processor');
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/hide/$id');
    final response = await http.put(uri, headers: _getHeaders());
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> update(Processor request) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/update/${request.id}');
    final response = await http.put(
      uri,
      headers: _getHeaders(),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update processor');
    }
  }

  // State Machine Methods
  Future<List<String>> getAllowedActions(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/allowedActions/$id');
    final response = await http.get(uri, headers: _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> actions = jsonDecode(response.body);
      return actions.map((e) => e.toString()).toList();
    } else {
      return [];
    }
  }

  Future<bool> activate(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/activate/$id');
    final response = await http.put(uri, headers: _getHeaders());
    return response.statusCode == 200;
  }

  Future<bool> edit(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/edit/$id');
    final response = await http.put(uri, headers: _getHeaders());
    return response.statusCode == 200;
  }

  Future<bool> hide(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/processor/hide/$id');
    final response = await http.put(uri, headers: _getHeaders());
    return response.statusCode == 200;
  }
}
