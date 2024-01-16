import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeValue(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

// Retrieve a string value
Future<String> getValue(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value = prefs.getString(key) ?? "Default";

  return value;
}
