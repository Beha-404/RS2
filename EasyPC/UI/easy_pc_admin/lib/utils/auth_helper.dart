import 'dart:convert';
import 'package:desktop/providers/user_provider.dart';

class AuthHelper {
  static Map<String, String> getAuthHeaders(UserProvider? userProvider) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    
    if (userProvider != null && 
        userProvider.username != null && 
        userProvider.password != null) {
      final credentials = '${userProvider.username}:${userProvider.password}';
      final encoded = base64Encode(utf8.encode(credentials));
      headers['Authorization'] = 'Basic $encoded';
    }
    
    return headers;
  }
}
