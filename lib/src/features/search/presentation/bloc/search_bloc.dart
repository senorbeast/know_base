import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../domain/entities/knowledge_bit.dart';
import '../../../../domain/repositories/knowledge_repository.dart';

part 'search_event.dart';
part 'search_state.dart';
part 'search_bloc.freezed.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final IKnowledgeRepository _repository;

  SearchBloc(this._repository) : super(const SearchState.initial()) {
    on<_QueryChanged>(_onQueryChanged, transformer: _debounce(const Duration(milliseconds: 500)));
  }

  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  Future<void> _onQueryChanged(_QueryChanged event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty && (event.tags == null || event.tags!.isEmpty)) {
      emit(const SearchState.initial());
      return;
    }

    emit(const SearchState.loading());
    try {
      final results = await _repository.searchKnowledgeBits(event.query, tags: event.tags);
      emit(SearchState.success(results));
    } catch (e) {
      emit(SearchState.failure(e.toString()));
    }
  }
}
