import 'package:flutter/material.dart';
import '../../classes/authstoragelist.dart';
import '../../data/color.dart';
import '../../data/styles.dart';
import '../../pages/registerpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../classes/authstorage.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _signinLoading = false;
  bool _signUpLoading = false;
  bool _obscureText = false;
  bool _isLoading = true; // برای نمایش پروگرس‌بار در هنگام بارگذاری اطلاعات

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthStorageList _authStorageList = AuthStorageList();
  List<Map<String, String>> users = [];

  final _formKey = GlobalKey<FormState>();
  String? selectedUser;
  String? selectedPassword;
  User? _user;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUsersCredentials();
  }

  Future<void> _loadUsersCredentials() async {
    List<Map<String, String>> loadedUsers = await _authStorageList.loadUsersCredentials();
    setState(() {
      users = loadedUsers;
      _isLoading = false;
    });
  }

  Future<void> _saveCredentials() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      if (!await _authStorageList.CheckUserExist(email)) {
        users.add({"username": email, "password": password});
        await _authStorageList.saveUsersCredentials(users);
      }
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در خروج از حساب: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ورود به حساب کاربری', style: CustomTextStyle.textappbar),
        backgroundColor: mzhColorThem1[3],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: mzhColorThem1[2],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "لطفا ایمیل معتبر و رمز ورود را وارد کرده و در صورتی که ثبت نام نکرده‌اید گزینه ثبت نام را انتخاب کنید.",
                style: CustomTextStyle.textreg,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30.0),
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: mzhColorThem1[1],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'ایمیل',
                              suffixIcon: users.isNotEmpty
                                  ? GestureDetector(
                                onTap: _showUserDialog,
                                child: const Icon(Icons.arrow_drop_down),
                              )
                                  : null,
                            ),
                          ),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'رمز عبور',
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                            obscureText: !_obscureText,
                          ),
                          SizedBox(height: 20.0),
                          _signinLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: mzhColorThem1[3],
                              foregroundColor: mzhColorThem1[2],
                              side: BorderSide(color: mzhColorThem1[2]),
                            ),
                            onPressed: () async {
                              setState(() => _signinLoading = true);
                              try {
                                final response = await supabase.auth.signInWithPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                setState(() => _user = response.user);
                                if (_user != null) {
                                  _saveCredentials();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: mzhColorThem1[0],
                                      content: Text(
                                        "ورود با موفقیت انجام شد.",
                                        style: CustomTextStyle.textsnackbar,
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context, _user);
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("خطایی در حین ورود اتفاق افتاده."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                setState(() => _signinLoading = false);
                              }
                            },
                            child: Text("ورود", style: CustomTextStyle.texten),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _signUpLoading
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => RegisterPage()),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: mzhColorThem1[2],
                foregroundColor: mzhColorThem1[2],
                side: BorderSide(color: mzhColorThem1[3]),
              ),
              child: Text("ثبت نام", style: CustomTextStyle.texten),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUserDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("انتخاب کاربر"),
          content: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: users.map((user) {
              return ListTile(
                title: Text(user['username']!),
                onTap: () {
                  setState(() {
                    selectedUser = user['username'];
                    selectedPassword = user['password'];
                    _emailController.text = selectedUser!;
                    _passwordController.text = selectedPassword!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [TextButton(child: Text("بستن"), onPressed: () => Navigator.pop(context))],
        );
      },
    );
  }
}
