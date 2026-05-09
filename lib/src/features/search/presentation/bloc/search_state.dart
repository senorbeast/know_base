part of 'search_bloc.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _Initial;
  const factory SearchState.loading() = _Loading;
  const factory SearchState.success(List<KnowledgeBit> results) = _Success;
  const factory SearchState.failure(String message) = _Failure;
}
