import 'package:json_annotation/json_annotation.dart';

part 'flashcard.g.dart';

@JsonSerializable()
class Flashcard {
  int id;
  String question;
  String answer;
  int level;
  String categoryid;


  Flashcard({required this.id, required this.question, required this.answer, required this.level,required this.categoryid});

  factory Flashcard.fromJson(Map<String, dynamic> data) => _$FlashcardFromJson(data);

  Map<String, dynamic> toJson() => _$FlashcardToJson(this);
}

//dart run build_runner build --delete-conflicting-outputs