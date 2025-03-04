part of 'category_bloc.dart';

@immutable
sealed class CategoryState {}

final class CategoryInitial extends CategoryState {}

final class CategoryInProgress extends CategoryState{}

final class CategorySuccess extends CategoryState{
  List<Map<String, dynamic> > lstCategory;

  CategorySuccess({required this.lstCategory});
}

final class CategoryFail extends CategoryState{}

final class CategoryEmpty extends CategoryState{}

