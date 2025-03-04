part of 'favorite_bloc.dart';

@immutable
sealed class FavoriteState {}

final class FavoriteInitial extends FavoriteState {}

final class FavoriteSelectInProgress extends FavoriteState{}

final class FavoriteIsSelectSuccess extends FavoriteState{
    bool isFavor;
    FavoriteIsSelectSuccess({required this.isFavor});
}

final class FavoriteIsSelectFail extends FavoriteState{}
////////////////////////////////////////////////////////////////////////////////
final class FavoriteInsertInProgress extends FavoriteState{}

final class FavoriteInsertSuccess extends FavoriteState{
    bool isFavor;
    FavoriteInsertSuccess({required this.isFavor});
}

final class FavoriteIsInsertFail extends FavoriteState{}
////////////////////////////////////////////////////////////////////////////////
final class FavoriteDeletProgress extends FavoriteState{}

final class FavoriteDeletSuccess extends FavoriteState{
    bool isFavor;
    FavoriteDeletSuccess({required this.isFavor});
}

final class FavoriteDeletFail extends FavoriteState{}