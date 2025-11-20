import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

class I18n {
  static Locale _locale = const Locale('en');
  static Map<String, dynamic> _map = {};

  static Locale get locale => _locale;

  static Future<void> load(Locale locale) async {
    _locale = locale;
    final code = locale.languageCode;
    final raw = await rootBundle.loadString('assets/i18n/$code.json');
    _map = jsonDecode(raw) as Map<String, dynamic>;
  }

  static String path(String path) {
    final parts = path.split('.');
    dynamic cur = _map;
    for (final p in parts) {
      if (cur is Map<String, dynamic> && cur.containsKey(p)) {
        cur = cur[p];
      } else {
        return path;
      }
    }
    return cur is String ? cur : path;
  }
}