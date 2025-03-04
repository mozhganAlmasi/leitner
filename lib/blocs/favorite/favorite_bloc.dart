import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../db/remote_favorite.dart';
import 'package:meta/meta.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteInitial()) {
    on<GetFavoriteEvent>(getFavoritIsSelect);
    on<SetFavoriteEvent>(insertFavoritItem);
    on<DeletFavoriteEvent>(deletFavoritItem);
  }

  FutureOr<void> getFavoritIsSelect(
      GetFavoriteEvent event,
      Emitter<FavoriteState> emit, ) async {
    emit(FavoriteSelectInProgress());

    try {

      final _isfavor = await RemoteFavorite.fetchFavorite(event.userid , event.sentencesid);

      if (_isfavor == null) {
        emit(
          FavoriteIsSelectFail(),
        );
      }  else {
        emit(
          FavoriteIsSelectSuccess( isFavor: _isfavor),
        );
      }
    } catch (e) {
      emit(
        FavoriteIsSelectFail(),
      );
    }
  }
  FutureOr<void> insertFavoritItem(
      SetFavoriteEvent event,
      Emitter<FavoriteState> emit, ) async {
    emit(FavoriteInsertInProgress());

    try {
      final _isfavor = await RemoteFavorite.insertFavorite(event.userid, event.sentencesid);
      if (_isfavor == null) {
        emit(
          FavoriteIsInsertFail(),
        );
      }  else {
        emit(
          FavoriteInsertSuccess( isFavor: _isfavor),
        );
      }
    } catch (e) {
      emit(
        FavoriteIsInsertFail(),
      );
    }
  }

  FutureOr<void> deletFavoritItem(
      DeletFavoriteEvent event,
      Emitter<FavoriteState> emit, ) async {
    emit(FavoriteDeletProgress());
    try {
      final _isfavor = await RemoteFavorite.deletFavorite(event.userid, event.sentencesid);
      if (_isfavor == null) {
        emit(
          FavoriteDeletFail(),
        );
      }  else {
        emit(
          FavoriteDeletSuccess( isFavor: _isfavor),
        );
      }
    } catch (e) {
      emit(
        FavoriteDeletFail(),
      );
    }
  }
}
