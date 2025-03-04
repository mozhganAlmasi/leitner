
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthStorageList {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ذخیره چند یوزر و پسورد به صورت آرایه
  Future<void> saveUsersCredentials(List<Map<String, String>> users) async {
    try {

      String jsonData = jsonEncode(users);
      await _storage.write(key: 'userCredentials', value: jsonData);
    } catch (e) {
      print('Error saving user credentials: $e');
    }
  }

  // بازیابی یوزرها و پسوردها
  Future<List<Map<String, String>>> loadUsersCredentials() async {
    try {
      String? jsonData = await _storage.read(key: 'userCredentials');

      if (jsonData != null) {
        List<dynamic> decodedData = jsonDecode(jsonData);

        // اطمینان از اینکه داده‌ها Map<String, dynamic> هستند
        List<Map<String, String>> usersList = decodedData
            .where((item) => item is Map<String, dynamic>) // فیلتر داده‌های نامعتبر
            .map((item) => (item as Map<String, dynamic>) // تبدیل نوع داده
            .map((key, value) => MapEntry(key, value.toString()))) // اطمینان از String بودن مقادیر
            .toList();

        return usersList;
      }
      return [];
    } catch (e) {
      print('Error loading user credentials: $e');
      return [];
    }
  }

  //چک کردن یوزر تکراری
  Future<bool> CheckUserExist(String currentUser) async {
    try {
      String? jsonData = await _storage.read(key: 'userCredentials');
      if (jsonData != null) {
        List<dynamic> decodedData = jsonDecode(jsonData);


        // اطمینان از این که داده‌ها ساختار مناسبی دارند
        List<Map<String, String>> usersList = decodedData
            .where((item) => item is Map)
            .map((item) => Map<String, String>.from(item))
            .toList();

        // بررسی اینکه آیا currentUser در لیست وجود دارد
        return usersList.any((user) => user['username'] == currentUser);

      }
      return false;
    } catch (e) {
      print('Error loading user credentials: $e');
      return false;
    }
  }

  // حذف یک یوزر از آرایه
  Future<void> deleteUser(String username) async {
    try {
      List<Map<String, String>> users = await loadUsersCredentials();
      users.removeWhere((user) => user['username'] == username);
      await saveUsersCredentials(users); // ذخیره دوباره لیست بروزشده
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  // حذف همه یوزرها و پسوردها
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }
}
