import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class ApiSettingsNotifier extends ChangeNotifier {
  static const _baseUrlKey = 'api_base_url';
  
  // Default IP for backend (Real backend at /api/)

   String _baseUrl = 'http://10.203.11.6:8000';

  String get baseUrl => _baseUrl;

  ApiSettingsNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_baseUrlKey) ?? _baseUrl;
    notifyListeners();
  }


  Future<void> updateBaseUrl(String newUrl) async {
    _baseUrl = newUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, newUrl);
    notifyListeners();
  }
}