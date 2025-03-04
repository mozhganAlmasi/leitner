part of 'flashcard_bloc.dart';

@immutable
sealed class FlashcardState {}

final class FlashcardInitial extends FlashcardState {

}
final class FlashcardInprogress extends FlashcardState {}
final class FlashcardLoadSuccess extends FlashcardState {
  List<Map<String , dynamic>> lstSentences ;
  FlashcardLoadSuccess({required this.lstSentences});
}
final class FlashcardLoadEmpty extends FlashcardState {}
final class FlashcardLoadFail extends FlashcardState {
  final String? message;
  FlashcardLoadFail(this.message);
}

final class GetCurrentUser extends FlashcardState{
  User user;
  GetCurrentUser({required this.user});
}
final class LoginUser extends FlashcardState{
String email;
String pass;

LoginUser({required this.email,required this.pass});
}

final class LogoutUser extends FlashcardState{

}



