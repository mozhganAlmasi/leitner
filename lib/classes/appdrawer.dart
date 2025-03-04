import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/color.dart';
import '../../data/styles.dart';
import '../../db/remote_users.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/authpage.dart';
import 'package:image/image.dart' as img;


class AppDrawer extends StatefulWidget {
  final VoidCallback onLogout; // تعریف callback
  AppDrawer({required this.onLogout});
  @override
  _AppDrawerState createState() => _AppDrawerState();
}
class _AppDrawerState extends State<AppDrawer> {
  bool isLogin = false;
  String? _imageUrl ="";
  User? _user;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _user = supabase.auth.currentUser;
    isLogin = _user != null;
    _loadImageUrl();
  }

  Future<void> _loadImageUrl() async {
    try{
      final imageUrl = await RemoteUsers.fetchImageURLFromUsersTable(_user!.email.toString());
      setState(() {
        _imageUrl = imageUrl;
      });
    }catch(e){

    }

  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: isLogin ? Text('', style: CustomTextStyle.textmenutitle) : Text(''),
            accountEmail: Text(isLogin ? (_user?.email ?? 'ایمیل نامشخص') : 'هیچ کاربری وارد نشده.'),
            currentAccountPicture: (_imageUrl == null || _imageUrl!.isEmpty)
                ? CircleAvatar(backgroundImage: AssetImage("assets/profile/profile.webp"))
                : CircleAvatar(backgroundImage: NetworkImage(_imageUrl!)),
            decoration: BoxDecoration(color: mzhColorThem1[2]),
          ),
          ListTile(
            leading: Icon(isLogin ? Icons.exit_to_app : Icons.login),
            title: Text(
              isLogin ? 'خروج از حساب کاربری' : 'ورود به حساب کاربری',
              style: CustomTextStyle.textmenu,
            ),
            onTap: () {
              if (isLogin) {
                logoutUser(context);
              } else {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => AuthPage()));
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.person_pin_outlined),
            title: Text(
              'تغییر تصویر پروفایل',
              style: isLogin ? CustomTextStyle.textmenu : CustomTextStyle.textmenudeactive,
            ),
            onTap: () async {
             if(isLogin)
               {
                 File? selectedFile = await pickImage();
                 if (selectedFile != null) {
                   String? imageUrl = await uploadProfileImage(selectedFile);
                   if (imageUrl != null) {
                     setState(() {
                       _imageUrl = imageUrl;
                     });
                   }
                 }
               }
            },
          ),
          ListTile(
            leading: Icon(Icons.close),
            title: Text('بستن برنامه', style: CustomTextStyle.textmenu),
            onTap: () {
              Navigator.pop(context);
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }

  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  Future<Uint8List> resizeImage(File imageFile, {int width = 200, int height = 200}) async {
    final imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) throw Exception("Failed to decode image");
    img.Image resizedImage = img.copyResize(image, width: width, height: height);
    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final fileExt = imageFile.path.split('.').last;
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      Uint8List resizedBytes = await resizeImage(imageFile);

      await supabase.storage.from('profile_image').uploadBinary(
        fileName,
        resizedBytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final imageUrl = supabase.storage.from('profile_image').getPublicUrl(fileName);

      if (imageUrl.isNotEmpty) {
        await RemoteUsers.updateUser(imageUrl, supabase.auth.currentUser!.email.toString());
      }

      return imageUrl;
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      widget.onLogout();
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در خروج از حساب: ${error.toString()}')),
      );
    }
  }
}

