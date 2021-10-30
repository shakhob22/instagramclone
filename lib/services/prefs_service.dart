import 'package:shared_preferences/shared_preferences.dart';

class Prefs{

  static Future<bool> saveUserId(String userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('userID', userID);
  }

  static Future<String?> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userID');
    return token;
  }

  static Future<bool> removeUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove('userID');
  }

  // Firebase Token
  static Future<bool> saveFCM(String fcmToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('fcm_token', fcmToken);
  }

  static Future<String?> loadFCM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('fcm_token');
    return token;
  }

}