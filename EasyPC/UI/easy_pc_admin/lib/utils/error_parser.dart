import 'dart:convert';
import 'package:http/http.dart' as http;

class ErrorParser {
  static String parseHttpError(http.Response response) {
    String errorMsg = 'Status ${response.statusCode}';
    
    try {
      final errorBody = jsonDecode(response.body);
      
      if (errorBody is Map && errorBody.containsKey('errors')) {
        final errors = errorBody['errors'] as Map;
        final errorList = <String>[];
        
        errors.forEach((key, value) {
          if (value is List) {
            for (var msg in value) {
              errorList.add('$key: $msg');
            }
          } else {
            errorList.add('$key: $value');
          }
        });
        
        if (errorList.isNotEmpty) {
          errorMsg = errorList.join('\n');
        }
      } 
      else if (errorBody is Map && errorBody.containsKey('title')) {
        errorMsg = errorBody['title'];
        if (errorBody.containsKey('detail')) {
          errorMsg += '\n${errorBody['detail']}';
        }
      }
      else if (errorBody is String) {
        errorMsg = errorBody;
      }
    } catch (_) {
      errorMsg = response.body.isNotEmpty ? response.body : errorMsg;
    }
    
    return errorMsg;
  }
}
