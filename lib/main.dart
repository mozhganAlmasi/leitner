import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:leitner_enper/blocs/category/category_bloc.dart';
import 'package:leitner_enper/blocs/favorite/favorite_bloc.dart';
import 'package:leitner_enper/pages/homepage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'blocs/flashcard/flashcard_bloc.dart';
import 'db/hivedb.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async{
  WidgetsBinding widgetsBinding =  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await LeitnerStorage().init(); // مقداردهی اولیه Hive فقط یک‌بار

  await dotenv.load();
  // WidgetsFlutterBinding.ensureInitialized();
  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseKey = dotenv.env['SUPABASE_KEY'] ?? '';
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) =>  runApp(LeitnerEnPer()));

}

class LeitnerEnPer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale("fa", "IR") , // OR Locale('ar', 'AE') OR Other RTL locales
        ],
        debugShowCheckedModeBanner: false,
        title: 'جملات پر کاربرد و ضروری',
        theme: ThemeData(
          primarySwatch: Colors.blue ,
        ),
        home: MultiBlocProvider(providers: [
          BlocProvider(
            create: (context) =>
            CategoryBloc()..add(GetCategoryEvent()) ,

          ),
          BlocProvider(
            create: (context) =>
            FlashcardBloc()..add(FlashcardFetchDataEvent()),

          ),
          BlocProvider(
            create: (context) =>
                FavoriteBloc(),

          ),

        ], child: HomePage()));
  }
}

