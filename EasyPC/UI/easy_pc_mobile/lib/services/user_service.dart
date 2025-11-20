import 'dart:convert';
import 'dart:typed_data';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class UserService {
  const UserService();

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/api/user/login');
    http.Response resp;
 
    try {
      resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );
    } catch (e) {
      throw Exception('Error occurred while logging in: $e');
    }

    if (resp.statusCode == 200 && resp.body.isNotEmpty) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return User.fromJson(data);
    } else {
      throw Exception('Login failed: ${resp.body}');
    }
  }

  Future<User> getUserById({required int id}) async {
    final uri = Uri.parse('$apiBaseUrl/api/User/get/$id');
    final resp = await http.get(uri, headers: {'Accept': 'application/json'});
    if (resp.statusCode >= 200 && resp.statusCode < 300 && resp.body.isNotEmpty) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) {
        return User.fromJson(decoded);
      }
      throw Exception('Unexpected response shape for GET /api/User/$id');
    }
    if (resp.statusCode == 404) {
      throw Exception('User with id=$id not found');
    }
    throw Exception('Fetch user by id failed (${resp.statusCode}): ${resp.body}');
  }

  Future<String> register({
    required String username,
    required String password,
    required String email,
  }) async {
    final url = Uri.parse('$apiBaseUrl/api/User/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Registration failed: ${response.body}');
    }
    return 'Registration successful';
  }


  Future<User> updateUser({required User user, Uint8List? profilePicture}) async {
    if (user.id == null) {
      throw Exception('Cannot update: user.id is required');
    }
    final uri = Uri.parse('$apiBaseUrl/api/User/update')
        .replace(queryParameters: {'id': user.id!.toString()});

  final payload = <String, dynamic>{};
  if (user.firstName != null) payload['firstName'] = user.firstName;
  if (user.lastName != null) payload['lastName'] = user.lastName;
  if (user.city != null) payload['city'] = user.city;
  if (user.state != null) payload['state'] = user.state;
  if (user.country != null) payload['country'] = user.country;
  if (user.postalCode != null) payload['postalCode'] = user.postalCode;
  if (user.address != null) payload['address'] = user.address;
  final pic = profilePicture ?? user.profilePicture;
  if (pic != null) payload['profilePicture'] = base64Encode(pic);

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final resp = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );

        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          return getUserById(id: user.id!);
      } else {
        throw Exception('Update failed (${resp.statusCode}): ${resp.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while updating user info: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/User/delete/$id');
    final resp = await http.put(uri, headers: {'Accept': 'application/json'});
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Delete failed (${resp.statusCode}): ${resp.body}');
    }
  }

  Future<void> restoreUser(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/User/restore/$id');
    final resp = await http.put(uri, headers: {'Accept': 'application/json'});
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Restore failed (${resp.statusCode}): ${resp.body}');
    }
  }
}
