import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteDataSource {
  static User? _user = null;

  static Future<List<Map<String, dynamic>>> fetchSentences() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('sentences') // نام جدول
        .select('id , question , answer , level , categoryid'); // انتخاب فیلدها
    if (response.isEmpty) {
      return [];
    }

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> fetchRandomSentences() async {
    final supabase = Supabase.instance.client;
    final response =
        await supabase.rpc('get_random_sentences', params: {'limit_val': 50});
    if (response.isEmpty) return [];
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> fetchSentencesByCategoryID(
      int categoryid) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('sentences') // نام جدول
        .select('id , question , answer , level , categoryid') // انتخاب فیلدها
        .eq("categoryid", categoryid);
    if (response.isEmpty) {
      return [];
    }

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<User> getCurrentUser() async {
    final SupabaseClient supabaseClient = Supabase.instance.client;
    _user = supabaseClient.auth.currentUser;
    supabaseClient.auth.onAuthStateChange.listen((event) {
      _user = event.session?.user;
    });
    return _user!;
  }

  static Future<bool> loginUser(String email, String pass) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.auth.signInWithPassword(
          email: email, // "almasi.sm@gmail.com",
          password: pass); //"123456789");
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logoutUser(String email, String pass) async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();
  }
}
