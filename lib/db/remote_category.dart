import 'package:supabase_flutter/supabase_flutter.dart';
class RemoteCategory{
  static  Future<List <Map<String , dynamic>>> fetchCategory() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('category') // نام جدول
        .select('id, name'); // انتخاب فیلدها

    if (response.isEmpty) {
      return [];
    }
    return List<Map<String, dynamic>>.from(response);
  }
}