import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imgify/models/pro_status.dart';

class ProStatusRepository {
  static const String _proStatusKey = 'pro_status';

  Future<ProStatus> getProStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_proStatusKey);

      if (jsonString == null) {
        return const ProStatus();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ProStatus.fromJson(json);
    } catch (e) {
      return const ProStatus();
    }
  }

  Future<void> saveProStatus(ProStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(status.toJson());
      await prefs.setString(_proStatusKey, jsonString);
    } catch (e) {
      return;
    }
  }

  Future<void> clearProStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_proStatusKey);
    } catch (e) {
      return;
    }
  }
}
