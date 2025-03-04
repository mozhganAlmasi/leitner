import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ذخیره ایمیل
  Future<void> saveEmail(String email) async {
    try {
      await _storage.write(key: 'email', value: email);
    } catch (e) {
      print('Error saving email: $e');
    }
  }

  // بازیابی ایمیل
  Future<String?> loadEmail() async {
    try {
      return await _storage.read(key: 'email');
    } catch (e) {
      print('Error loading email: $e');
      return null;
    }
  }

  // حذف ایمیل
  Future<void> deleteEmail() async {
    try {
      await _storage.delete(key: 'email');
    } catch (e) {
      print('Error deleting email: $e');
    }
  }


// ذخیره پسورد
  Future<void> savePassword(String password) async {
    try {
      await _storage.write(key: 'password', value: password);
    } catch (e) {
      print('Error saving password: $e');
    }
  }

  // بازیابی پسورد
  Future<String?> loadPassword() async {
    try {
      return await _storage.read(key: 'password');
    } catch (e) {
      print('Error loading password: $e');
      return null;
    }
  }
  // حذف اطلاعات (ایمیل و پسورد)
  Future<void> deleteCredentials() async {
    try {
      await _storage.delete(key: 'email');
      await _storage.delete(key: 'password');
    } catch (e) {
      print('Error deleting credentials: $e');
    }
  }
  // حذف همه داده‌ها (در مواقع لاگ‌اوت)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing storage: $e');
    }
  }
}
