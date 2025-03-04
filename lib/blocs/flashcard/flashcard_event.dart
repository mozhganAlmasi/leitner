part of 'flashcard_bloc.dart';

@immutable
sealed class FlashcardEvent {}
final class FlashcardFetchDataEvent extends FlashcardEvent {
  FlashcardFetchDataEvent();
}
final class FlashcardFetchDataByGroupEvent extends FlashcardEvent{
  final int groupID;
  FlashcardFetchDataByGroupEvent(this.groupID);
}
final class GetCurrentUserEvent  extends FlashcardEvent {
  GetCurrentUserEvent();
}
final class FlashcardSearchEvent extends FlashcardEvent{
  final String STRen;
  FlashcardSearchEvent(this.STRen);
}
