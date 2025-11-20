import 'dart:convert';
import 'package:easy_pc/providers/user_provider.dart';

class AuthHelper {
  static Map<String, String> getAuthHeaders(UserProvider? userProvider) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (userProvider != null && 
        userProvider.user?.username != null && 
        userProvider.password != null) {
      final credentials = '${userProvider.user!.username}:${userProvider.password}';
      final encoded = base64Encode(utf8.encode(credentials));
      headers['Authorization'] = 'Basic $encoded';
    }
    
    return headers;
  }

  static Map<String, String> getAuthHeadersFromCredentials(String username, String password) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    final credentials = '$username:$password';
    final encoded = base64Encode(utf8.encode(credentials));
    headers['Authorization'] = 'Basic $encoded';
    
    return headers;
  }
}
