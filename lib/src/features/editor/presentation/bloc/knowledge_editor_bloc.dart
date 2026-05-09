import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../domain/entities/content_block.dart';
import '../../../../domain/entities/knowledge_bit.dart';
import '../../../../domain/repositories/knowledge_repository.dart';

part 'knowledge_editor_event.dart';
part 'knowledge_editor_state.dart';
part 'knowledge_editor_bloc.freezed.dart';

@injectable
class KnowledgeEditorBloc extends Bloc<KnowledgeEditorEvent, KnowledgeEditorState> {
  final IKnowledgeRepository _repository;

  KnowledgeEditorBloc(this._repository) : super(const KnowledgeEditorState.initial()) {
    on<_TitleChanged>(_onTitleChanged, transformer: _debounce(const Duration(milliseconds: 800)));
    on<_BlocksChanged>(_onBlocksChanged, transformer: _debounce(const Duration(milliseconds: 800)));
    on<_SaveRequested>(_onSaveRequested);
  }

  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  Future<void> _onTitleChanged(_TitleChanged event, Emitter<KnowledgeEditorState> emit) async {
    // Autosave logic could go here
  }

  Future<void> _onBlocksChanged(_BlocksChanged event, Emitter<KnowledgeEditorState> emit) async {
    // Autosave logic could go here
  }

  Future<void> _onSaveRequested(_SaveRequested event, Emitter<KnowledgeEditorState> emit) async {
    emit(const KnowledgeEditorState.saving());
    try {
      await _repository.createKnowledgeBit(event.bit);
      emit(const KnowledgeEditorState.success());
    } catch (e) {
      emit(KnowledgeEditorState.failure(e.toString()));
    }
  }
}
