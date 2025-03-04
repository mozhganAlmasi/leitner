import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../data/styles.dart';
import '../../db/hivedb.dart';
import '../../pages/authpage.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../blocs/flashcard/flashcard_bloc.dart';
import '../classes/appdrawer.dart';
import '../data/color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final SupabaseClient supabase = Supabase.instance.client;
User? _user;

List<String> lstCategoryDropdownName = ["همه گروه ها"];
List<Map<String, dynamic>> lstCateGoryNamesWithIds = [];

String dropdownValueCategory = "همه گروه ها";

int currentRowSentences = 0; //شمارنده گروه جاری

bool _isButtonVisible = false;

bool isFavorit = false;
String imgFavorit = "assets/icons/favoritdeselect.png";

FlutterTts _flutterTts = FlutterTts();

List<Map<String, dynamic>> lstSentencesMain = [];
List<Map<String, dynamic>> lstHiveSentenceReview = [];

String sentenceSpeak = "";
int sentenceID = 0;
int sentenceStage = 0;

bool changeGroup = true;

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _readFromHive(); // بارگیری داده‌های ذخیره‌شده
  }

  void _readFromHive() async {
    lstHiveSentenceReview = await LeitnerStorage().getDueReviewsSentence();
    print("ListReview:" + lstHiveSentenceReview.toString());
  }

  void removeSentencesReaded() async {
    try {
      List<int> idsToRemove = await LeitnerStorage().getAllIdsInHive();
      // استخراج IDهای موجود در lstHiveSentenceReview
      final hiveIds = lstHiveSentenceReview.map((item) => item["id"]).toSet();

      if (idsToRemove.length > 0)
        setState(() {
// حذف فقط مواردی که در idsToRemove هستند اما در hiveIds نیستند
          lstSentencesMain.removeWhere((sentence) =>
              idsToRemove.contains(sentence["id"]) &&
              !hiveIds.contains(sentence["id"]));
        });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _user = supabase.auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جعبه لایتنر',
          style: CustomTextStyle.textappbar,
        ),
        backgroundColor: mzhColorThem1[3],
      ),
      drawer: AppDrawer(onLogout: _onLogout),
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          color: mzhColorThem1[2],
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategorySuccess) {
                    if (lstCategoryDropdownName.length == 1) {
                      List<String> names = state.lstCategory
                          .map((item) => item["name"].toString())
                          .toList();
                      lstCateGoryNamesWithIds = state.lstCategory
                          .map((item) =>
                              {"id": item["id"], "name": item["name"]})
                          .toList();
                      lstCategoryDropdownName = lstCategoryDropdownName + names;
                    }

                    return Container(
                      height: size.height * .08,
                      width: size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(
                            color: Colors.grey,
                            style: BorderStyle.solid,
                            width: 0.80),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Center(
                          child: DropdownButton<String>(
                              menuMaxHeight: size.height * .5,
                              value: dropdownValueCategory,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 6,
                              style: const TextStyle(color: Colors.deepPurple),
                              underline: Container(
                                color: Colors.deepPurpleAccent,
                              ),
                              items: lstCategoryDropdownName
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem(
                                    value: value,
                                    child: Container(
                                      width: size.width * .6,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        border: Border.all(
                                            color: mzhColorThem1[2],
                                            style: BorderStyle.solid,
                                            width: 0.80),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(7.0),
                                        child: Text(
                                          value,
                                          style:
                                              CustomTextStyle.textdropdownitem,
                                        ),
                                      ),
                                    ));
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  currentRowSentences = 0;
                                  changeGroup = true;
                                  dropdownValueCategory = value ?? "";
                                  int resultId = lstCateGoryNamesWithIds.firstWhere(
                                      (item) => item["name"] == value,
                                      orElse: () => {
                                            "id": -1
                                          } // در صورتی که هیچ سطری پیدا نشد، -1 را برمی‌گرداند
                                      )["id"];
                                  if (resultId == -1) {
                                    context
                                        .read<FlashcardBloc>()
                                        .add(FlashcardFetchDataEvent());
                                  } else {
                                    context.read<FlashcardBloc>().add(
                                        FlashcardFetchDataByGroupEvent(
                                            resultId));
                                  }
                                });
                              }),
                        ),
                      ),
                    );
                  }
                  return Container(
                    width: size.width / 2,
                    height: size.height / 10,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: mzhColorThem1[3],
                  width: size.width - 16,
                  child: Card(
                    color: mzhColorThem1[1],
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        BlocBuilder<FlashcardBloc, FlashcardState>(
                          builder: (context, state) {
                            if (state is FlashcardInprogress) {
                              return SizedBox(
                                height: 200, //size.height/5,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            mzhColorThem1[3],
                                            mzhColorThem1[2],
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              color: Colors.red,
                                            ),
                                            Text("Loading..."),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else if (state is FlashcardLoadSuccess) {
                              if(changeGroup)
                                { lstSentencesMain = state.lstSentences;
                                removeSentencesReaded();
                                  changeGroup = false;
                                }

                              if (currentRowSentences >=
                                  lstSentencesMain.length) {
                                currentRowSentences = 0; // یا مقدار مناسب بده
                              }
                              sentenceSpeak =
                                  lstSentencesMain[currentRowSentences]
                                      ["question"];
                              sentenceID =
                                  lstSentencesMain[currentRowSentences]["id"];
                              sentenceStage = lstHiveSentenceReview.firstWhere(
                                (item) => item['id'] == sentenceID,
                                orElse: () => {'next_interval_days': 0},
                              )['next_interval_days'];

                              _checkIsSelectFavorite(sentenceID);
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        sentenceSpeak,
                                        style: CustomTextStyle.texten,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  if (_isButtonVisible)
                                    AnimatedOpacity(
                                      opacity: _isButtonVisible ? 1.0 : 0.0,
                                      duration: Duration(milliseconds: 500),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          lstSentencesMain[currentRowSentences]
                                              ["answer"],
                                          style: CustomTextStyle.texten,
                                        ),
                                      ),
                                    ),
                                  if (!_isButtonVisible)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: mzhColorThem1[3], // رنگ دکمه
                                        onPrimary: mzhColorThem1[5], // رنگ متن
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isButtonVisible = !_isButtonVisible;
                                        });
                                      },
                                      child: Text(
                                        'نمایش پاسخ',
                                        style: CustomTextStyle.textbutton,
                                      ),
                                    ),
                                ],
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                color: mzhColorThem1[3],
                                width: size.width,
                                child: Card(
                                  color: mzhColorThem1[1],
                                  child: SizedBox(
                                    height: 400,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "داه ای برای نمایش یافت نشد.",
                                            style: CustomTextStyle.textbutton,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        AnimatedOpacity(
                                          opacity: _isButtonVisible ? 1.0 : 0.0,
                                          duration: Duration(milliseconds: 500),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "داده ای برای نمایش وجود ندارد",
                                              style: CustomTextStyle.textbutton,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        if (_isButtonVisible)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: mzhColorThem1[4], // رنگ دکمه
                                  onPrimary: mzhColorThem1[6], // رنگ متن
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isButtonVisible = !_isButtonVisible;
                                    if (currentRowSentences <
                                        lstSentencesMain.length - 1) {
                                      currentRowSentences++;
                                      _checkIsSelectFavorite(sentenceID);
                                    }
                                    _readFromHive();
                                    LeitnerStorage().saveReview(
                                        sentenceID, DateTime.now(), 0);
                                  });
                                },
                                child: Text(
                                  'اشتباه جواب دادم',
                                  style: CustomTextStyle.textbutton,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: mzhColorThem1[5], // رنگ دکمه
                                  onPrimary: mzhColorThem1[6], // رنگ متن
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isButtonVisible = !_isButtonVisible;
                                    if (currentRowSentences <
                                        lstSentencesMain.length - 1) {
                                      currentRowSentences++;
                                      _checkIsSelectFavorite(sentenceID);
                                    }
                                  });

                                  sentenceStage += 1;
                                  LeitnerStorage().saveReview(sentenceID,
                                      DateTime.now(), sentenceStage);
                                },
                                child: Text(
                                  'بلد بودم',
                                  style: CustomTextStyle.textbutton,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BlocBuilder<FavoriteBloc, FavoriteState>(
                              builder: (context, state) {
                                if (state is FavoriteIsSelectSuccess) {
                                  isFavorit = state.isFavor;
                                }
                                if (state is FavoriteDeletSuccess)
                                  isFavorit = false;
                                if (state is FavoriteInsertSuccess)
                                  isFavorit = true;
                                imgFavorit = (isFavorit && _user != null)
                                    ? "assets/icons/favoritselect.png"
                                    : "assets/icons/favoritdeselect.png";

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      _changStateFavorite(sentenceID);
                                    },
                                    child: Image(
                                      image: AssetImage(imgFavorit),
                                      width: size.width * .1,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  _flutterTts.speak(sentenceSpeak);
                                },
                                child: CircleAvatar(
                                  backgroundColor: mzhColorThem1[2],
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image(
                                      image: AssetImage(
                                          "assets/icons/speaker.png"),
                                      width: size.width * .1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkIsSelectFavorite(int sentenceid) {
    try {
      if (_user != null) {
        context.read<FavoriteBloc>().add(
              GetFavoriteEvent(userid: _user!.id!, sentencesid: sentenceid!),
            );
      }
    } catch (e) {}
  }

  void _changStateFavorite(int sentenceid) {
    _user = Supabase.instance.client.auth.currentUser;
    if (_user == null)
      _navigateToLogin();
    else {
      if (isFavorit)
        context
            .read<FavoriteBloc>()
            .add(DeletFavoriteEvent(_user!.id, sentenceid));
      else
        context
            .read<FavoriteBloc>()
            .add(SetFavoriteEvent(_user!.id, sentenceid));
    }
  }

  void _navigateToLogin() async {
    final user = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AuthPage()));

    if (user != null) {
      setState(() {
        _user = user; // مقداردهی به _user با اطلاعات جدید
      });
    }
  }

  void _checkUserStatus() {
    final user = Supabase.instance.client.auth.currentUser;

    setState(() {
      _user = user;
      if (user == null) imgFavorit = "assets/icons/favoritdeselect.png";
    });
  }

  // تابعی که می‌خوای بعد از لاگ‌اوت اجرا بشه
  void _onLogout() {
    _checkUserStatus();
  }
}
