import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteUsers{
  static Future<bool> fetchUsers(String email) async {
    try
    {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('users') // نام جدول شما
          .select('id') // انتخاب همه فیلدها
          .eq('email', email) ;
      // انتخاب فیلدها
      print(response);
      var lenResponce =  List<Map<String , dynamic>>.from(response).length ;
      if (response != null  && lenResponce > 0){
        return true;
      }
      return false;
    }catch(e){
      return false;
      print(e.toString());
    }
  }
  static Future<String> fetchImageURLFromUsersTable(String email) async {
    try
    {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('users') // نام جدول شما
          .select('img') // انتخاب همه فیلدها
          .eq('email', email)
          .single();
      print(response['img'].toString());
      return response['img'].toString();

    }catch(e){
      return "";
    }
  }

  static Future<bool> insertUser(String email) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('users').insert([
        {
          'email': email, // شناسه کاربر
        }
      ]).execute();
      return true;
    } catch (e) {
      return false;
    }
  }
  static Future<bool> updateUser(String img , String email) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase
          .from('users')
          .update({'img':img})
      .eq('email', email);
      return true;
    } catch (e) {
      return false;
    }
  }
  static Future<bool> deletUser(String userid, int sentencesid) async {
    final supabase = Supabase.instance.client;

   try{
     final response = await supabase
         .from('users') // نام جدول
         .delete() // عملیات حذف
         .eq('userid', userid) // شرط اول
         .eq('sentencesid', sentencesid) // شرط دوم
         .execute();
     return true;
   }
   catch(e){
     return false;
   }

  }
}
