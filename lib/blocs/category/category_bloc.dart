import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../db/remote_category.dart';

part 'category_event.dart';

part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<GetCategoryEvent>(getListCategory);
  }

  FutureOr<void> getListCategory(
    GetCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryInProgress());

    try {
      final cateoryList = await RemoteCategory.fetchCategory();

      if (cateoryList == null) {
        emit(
          CategoryFail(),
        );
      } else if (cateoryList.isEmpty) {
        emit(CategoryEmpty());
      } else {
        emit(
          CategorySuccess(lstCategory: cateoryList),
        );
      }
    } catch (e) {
      emit(
        CategoryFail(),
      );
    }
  }
}
