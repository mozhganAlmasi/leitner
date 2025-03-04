import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/color.dart';
import '../../data/styles.dart';
import '../../db/remote_users.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links3/uni_links.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _signUpLoading = false;
  bool _obscureTextpass = false;
  bool _obscureTextrepass = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repasswordController = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  String? savedEmail; // برای ذخیره ایمیل ذخیره‌شده
  String? savedPassword;
  User? _user;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  Future<void> _handleIncomingLinks() async {
    final initialLink = await getInitialUri();
    if (initialLink != null) {
      await _processLink(initialLink);
    }
    // بررسی لینک‌های جدید وقتی اپ بازه
    uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          try {
            _processLink(uri);
          } catch (e) {
            print('Error processing link: $e');
          }
        }
      },
      onError: (err) {
        print('Stream error: $err');
      },
    );
    // بررسی لینک اولیه هنگام باز شدن اپ
  }

  Future<void> _processLink(Uri uri) async {
    try {
      // استخراج توکن‌ها از fragment (بعد از # در URL)
      final fragment = uri.fragment;
      final params = Uri.splitQueryString(fragment);

      final accessToken = params['access_token'];
      final refreshToken = params['refresh_token'];
      final expiresAt = params['expires_at'];

      if (accessToken != null && refreshToken != null && expiresAt != null) {
        await supabase.auth.signInWithPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        _user = Supabase.instance.client.auth.currentUser;
        RemoteUsers.insertUser(_emailController.text);
        Navigator.pop(context, _user);

      } else {
        debugPrint('برخی از پارامترهای ضروری یافت نشدند.');
      }
    } catch (e) {
      debugPrint('خطا در پردازش Callback: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ثبت نام',
          style: CustomTextStyle.textappbar,
        ),
        backgroundColor: mzhColorThem1[3],
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: Container(
        color: mzhColorThem1[2],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "لطفا ایمیل معتبر وارد کنید ، لینک تایید به ایمیل شما ارسال خواهد شد.",
                    style: CustomTextStyle.textreg),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: mzhColorThem1[1],
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center ,
                        crossAxisAlignment: CrossAxisAlignment.stretch ,
                        children: [
                          TextField(
                            controller: _emailController ,
                            decoration: InputDecoration(
                              labelText: 'ایمیل',
                              suffixIcon: savedEmail != null
                                  ? GestureDetector(
                                      onTap: () {
                                        _emailController.text = savedEmail!;
                                      },
                                      child: const Icon(Icons.arrow_drop_down),
                                    )
                                  : null,
                            ),
                            onTap: () {
                              // if (savedEmail != null) {
                              //   _emailController.text = savedEmail!;
                              // }
                            },
                          ),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                                labelText: 'رمز عبور',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureTextpass = !_obscureTextpass;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureTextpass
                                        ? Icons.visibility_off
                                        : Icons
                                            .visibility, // تغییر آیکن بر اساس وضعیت
                                  ),
                                )),
                            obscureText: (_obscureTextpass) ?false:true,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          TextField(
                            controller: _repasswordController,
                            decoration: InputDecoration(
                                labelText: ' تکرار رمز عبور',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureTextrepass = !_obscureTextrepass;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureTextrepass
                                        ? Icons.visibility_off
                                        : Icons
                                            .visibility, // تغییر آیکن بر اساس وضعیت
                                  ),
                                )),
                            obscureText: (_obscureTextrepass) ?false:true,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          _signUpLoading
                              ? const Center(
                            child: CircularProgressIndicator() ,
                          )
                              : OutlinedButton(
                            onPressed: () async {
                              try {
                                if(await RemoteUsers.fetchUsers(_emailController.text))
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "این ایمیل قبلا ثبت نام شده. " ,
                                          style: CustomTextStyle.textreg ,
                                        ),
                                        backgroundColor: mzhColorThem1[2] ,
                                      ),
                                    );
                                    return;
                                  }
                                if (_passwordController.text !=
                                    _repasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "رمز ورود و تکرار رمز ورود یکسان نیستند. " ,
                                        style: CustomTextStyle.textreg ,
                                      ),
                                      backgroundColor: mzhColorThem1[2] ,
                                    ),
                                  );
                                } else if (isValidPassword(_passwordController.text) &&
                                    isValidPassword(_repasswordController.text)) {
                                  setState(() {
                                    _signUpLoading = true ;
                                  });
                                  var responce = await supabase.auth.signUp(
                                    email: _emailController.text ,
                                    password: _passwordController.text ,
                                    emailRedirectTo: 'linguaflash://auth/callback' ,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      "لینک تایید ارسال شد",
                                      style: CustomTextStyle.textreg,
                                    ),
                                    backgroundColor: mzhColorThem1[2],
                                  ));
                                  setState(() {
                                    _signUpLoading = false;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      " رمز ورود باید شامل حروف کوچک و بزرگ انگلیسی ، اعداد و کاراکترهای خاص و حداقل شش کاراکتر باشد ",
                                      style: CustomTextStyle.textreg,
                                    ),
                                    backgroundColor: mzhColorThem1[2],
                                  ));
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("خطا در ثبت نام"),
                                  backgroundColor: mzhColorThem1[2],
                                ));
                                print(e.toString());
                                setState(() {
                                  _signUpLoading = false;
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: mzhColorThem1[3],
                              foregroundColor: mzhColorThem1[2], // تغییر رنگ متن
                              side: BorderSide(
                                  color: mzhColorThem1[3]), // تغییر رنگ حاشیه
                            ),
                            child: Text(
                              "ثبت نام",
                              style: CustomTextStyle.texten,
                            ),
                          ),
                          /*  sing up button  */
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  bool isValidPassword(String password) {
    // بررسی طول پسورد
    if (password.length < 6) return false;

    // بررسی وجود حروف بزرگ
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));

    // بررسی وجود حروف کوچک
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));

    // بررسی وجود عدد
    bool hasDigit = password.contains(RegExp(r'\d'));

    // بررسی وجود کاراکترهای خاص
    bool hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

    // بازگرداندن نتیجه نهایی
    return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }


}
