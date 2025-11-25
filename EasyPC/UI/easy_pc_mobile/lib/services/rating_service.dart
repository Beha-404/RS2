import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/rating.dart';
import 'package:http/http.dart' as http;

class RatingService {
  const RatingService();

  Future<Rating?> insert({
    required int userId,
    required int pcId,
    required int ratingValue,
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/api/rating/insert');
    final credentials = base64Encode(utf8.encode('$username:$password'));

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $credentials',
        },
        body: jsonEncode({
          'userId': userId,
          'pcId': pcId,
          'ratingValue': ratingValue,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return Rating.fromJson(json as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create rating: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create rating: $e');
    }
  }

  Future<List<Rating>> getUserPcRatings({
    required int userId,
    required int pcId,
  }) async {
    final queryParams = {
      'userId': userId.toString(),
      'pcId': pcId.toString(),
    };

    final uri = Uri.parse('$apiBaseUrl/api/rating/get/all')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        return json.map((item) => Rating.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load ratings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load ratings: $e');
    }
  }

  Future<Rating?> update({
    required int id,
    required int ratingValue,
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/api/rating/update/$id');
    final credentials = base64Encode(utf8.encode('$username:$password'));

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $credentials',
        },
        body: jsonEncode({
          'ratingValue': ratingValue,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Rating.fromJson(json as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update rating: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update rating: $e');
    }
  }

  Future<bool> delete(
    int id, {
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/api/rating/delete/$id');
    final credentials = base64Encode(utf8.encode('$username:$password'));

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete rating: $e');
    }
  }
}
