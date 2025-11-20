import 'dart:convert';

import 'package:desktop/config/config.dart';
import 'package:desktop/models/products.dart';
import 'package:http/http.dart' as http;

class ProductsService {
  Future<List<Products>> getAllProducts() async {
    final uri = Uri.parse('$apiBaseUrl/api/products/get/all');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((e) => Products.fromJson(e)).toList();
      } else if (decoded is Map<String, dynamic>) {
        return [Products.fromJson(decoded)];
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load products');
    }
  }
}