part of 'favorite_bloc.dart';

@immutable
sealed class FavoriteEvent {}
final class GetFavoriteEvent extends FavoriteEvent{
  String userid;
  int sentencesid;

  GetFavoriteEvent({required this.userid, required this.sentencesid});
}

final class SetFavoriteEvent extends FavoriteEvent{
  String userid;
  int sentencesid;

  SetFavoriteEvent(this.userid, this.sentencesid);
}
final class DeletFavoriteEvent extends FavoriteEvent{
  String userid;
  int sentencesid;

  DeletFavoriteEvent(this.userid, this.sentencesid);
}
