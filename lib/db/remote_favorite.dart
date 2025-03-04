import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteFavorite {
  static Future<bool> fetchFavorite(String userid, int sentencesid) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('favorite') // نام جدول شما
        .select('id') // انتخاب همه فیلدها
        .eq('userid', userid)
        .eq('sentencesid', sentencesid)
        .execute();
    // انتخاب فیلدها
    if (response.data != null  && response.data.isNotEmpty){
      return true;
    }
    return false;
  }

  static Future<bool> insertFavorite(String userid, int sentencesid) async {
    final supabase = Supabase.instance.client;

    try{
      await supabase.from('favorite').insert([
        {
          'userid': userid, // شناسه کاربر
          'sentencesid': sentencesid, // شناسه جمله
        }
      ]).execute();
      return true;
    }catch(e){
      return  false;
    }

  }
  static Future<bool> deletFavorite(String userid, int sentencesid) async {
    final supabase = Supabase.instance.client;

   try{
     final response = await supabase
         .from('favorite') // نام جدول
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
