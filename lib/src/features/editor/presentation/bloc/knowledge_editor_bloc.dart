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

  KnowledgeEditorBloc(this._repository) : super(KnowledgeEditorState.initial()) {
    on<_Initialize>(_onInitialize);
    on<_TitleChanged>(_onTitleChanged);
    on<_BlockAdded>(_onBlockAdded);
    on<_BlockUpdated>(_onBlockUpdated);
    on<_TagsChanged>(_onTagsChanged);
    on<_PriorityChanged>(_onPriorityChanged);
    on<_Reset>(_onReset);
    on<_AutoSave>(
      _onAutoSave,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 1000)).switchMap(mapper),
    );
  }

  Future<void> _onInitialize(_Initialize event, Emitter<KnowledgeEditorState> emit) async {
    if (event.existingBit != null) {
      await _repository.setLastActiveKnowledgeBit(event.existingBit!.id);
      emit(state.copyWith(
        bit: event.existingBit!,
        saveStatus: SaveStatus.initial,
        isDirty: false,
      ));
    } else {
      final lastActive = await _repository.getLastActiveKnowledgeBit();
      if (lastActive != null) {
        emit(state.copyWith(
          bit: lastActive,
          saveStatus: SaveStatus.initial,
          isDirty: false,
        ));
      } else {
        emit(KnowledgeEditorState.initial());
      }
    }
  }

  void _onTitleChanged(_TitleChanged event, Emitter<KnowledgeEditorState> emit) {
    emit(state.copyWith(
      bit: state.bit.copyWith(
        title: event.title,
        updatedAt: DateTime.now(),
      ),
      isDirty: true,
      saveStatus: SaveStatus.initial,
    ));
    add(const KnowledgeEditorEvent.autoSave());
  }

  void _onBlockAdded(_BlockAdded event, Emitter<KnowledgeEditorState> emit) {
    emit(state.copyWith(
      bit: state.bit.copyWith(
        blocks: [...state.bit.blocks, event.block],
        updatedAt: DateTime.now(),
      ),
      isDirty: true,
      saveStatus: SaveStatus.initial,
    ));
    add(const KnowledgeEditorEvent.autoSave());
  }

  void _onBlockUpdated(_BlockUpdated event, Emitter<KnowledgeEditorState> emit) {
    final updatedBlocks = List<ContentBlock>.from(state.bit.blocks);
    if (event.index >= 0 && event.index < updatedBlocks.length) {
      updatedBlocks[event.index] = event.block;
    }
    emit(state.copyWith(
      bit: state.bit.copyWith(
        blocks: updatedBlocks,
        updatedAt: DateTime.now(),
      ),
      isDirty: true,
      saveStatus: SaveStatus.initial,
    ));
    add(const KnowledgeEditorEvent.autoSave());
  }

  void _onTagsChanged(_TagsChanged event, Emitter<KnowledgeEditorState> emit) {
    emit(state.copyWith(
      bit: state.bit.copyWith(
        tags: event.tags,
        updatedAt: DateTime.now(),
      ),
      isDirty: true,
      saveStatus: SaveStatus.initial,
    ));
    add(const KnowledgeEditorEvent.autoSave());
  }

  void _onPriorityChanged(_PriorityChanged event, Emitter<KnowledgeEditorState> emit) {
    emit(state.copyWith(
      bit: state.bit.copyWith(
        priority: event.priority,
        updatedAt: DateTime.now(),
      ),
      isDirty: true,
      saveStatus: SaveStatus.initial,
    ));
    add(const KnowledgeEditorEvent.autoSave());
  }

  Future<void> _onReset(_Reset event, Emitter<KnowledgeEditorState> emit) async {
    await _repository.clearLastActiveKnowledgeBit();
    emit(KnowledgeEditorState.initial());
  }

  Future<void> _onAutoSave(_AutoSave event, Emitter<KnowledgeEditorState> emit) async {
    if (!state.isDirty || state.bit.title.trim().isEmpty) return;

    emit(state.copyWith(saveStatus: SaveStatus.saving));
    try {
      await _repository.updateKnowledgeBit(state.bit);
      await _repository.setLastActiveKnowledgeBit(state.bit.id);
      emit(state.copyWith(
        saveStatus: SaveStatus.success,
        isDirty: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        saveStatus: SaveStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
