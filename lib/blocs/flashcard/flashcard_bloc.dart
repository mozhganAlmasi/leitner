import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';

import '../../db/remote_data_source.dart';

part 'flashcard_event.dart';
part 'flashcard_state.dart';

class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  FlashcardBloc() : super(FlashcardInitial()) {
    on<FlashcardFetchDataEvent>(getFlashcardList);
    on<FlashcardFetchDataByGroupEvent>(getFlashcardListByGroup);
    on<GetCurrentUserEvent>(getCurrentUser);
  }

  FutureOr<void> getFlashcardList(
      FlashcardFetchDataEvent event,
      Emitter<FlashcardState> emit, ) async {
    emit(FlashcardInprogress());

    try {

      final flashcardList = await RemoteDataSource.fetchRandomSentences( );

      if (flashcardList == null) {
        emit(
          FlashcardLoadFail("Some Errors Occured."),
        );
      } else if (flashcardList.isEmpty) {
        emit(FlashcardLoadEmpty());
      } else {
        emit(
          FlashcardLoadSuccess(lstSentences: flashcardList ),
        );
      }
    } catch (e) {
      emit(
        FlashcardLoadFail(
          e.toString(),
        ),
      );
    }
  }
  FutureOr<void> getFlashcardListByGroup(
      FlashcardFetchDataByGroupEvent event,
      Emitter<FlashcardState> emit, ) async {
    emit(FlashcardInprogress());

    try {

      final flashcardList = await RemoteDataSource.fetchSentencesByCategoryID(event.groupID);

      if (flashcardList == null) {
        emit(
          FlashcardLoadFail("Some Errors Occured."),
        );
      } else if (flashcardList.isEmpty) {
        emit(FlashcardLoadEmpty());
      } else {
        emit(
          FlashcardLoadSuccess(lstSentences: flashcardList ),
        );
      }
    } catch (e) {
      emit(
        FlashcardLoadFail(
          e.toString(),
        ),
      );
    }
  }
  FutureOr<void> getCurrentUser(
      GetCurrentUserEvent event,
      Emitter<FlashcardState> emit, ) async {
    try {
      final User _user = await RemoteDataSource.getCurrentUser();
      if (_user == null) {
      } else if (_user.email == null) {
      } else {
        emit(
         GetCurrentUser(user: _user)
        );
      }
    } catch (e) {
    }
  }
}
