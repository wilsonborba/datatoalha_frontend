import 'package:shared_preferences/shared_preferences.dart';
import '../../core/settings.dart';

class StorageAdapter {
  Future<void> saveAdminToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppSettings.adminTokenKey, token);
  }

  Future<String?> getAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppSettings.adminTokenKey);
  }
}
