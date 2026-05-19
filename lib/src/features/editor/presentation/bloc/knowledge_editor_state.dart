part of 'knowledge_editor_bloc.dart';

enum SaveStatus {
  initial,
  saving,
  success,
  failure,
}

@freezed
class KnowledgeEditorState with _$KnowledgeEditorState {
  const factory KnowledgeEditorState({
    required KnowledgeBit bit,
    required SaveStatus saveStatus,
    required bool isDirty,
    String? errorMessage,
  }) = _KnowledgeEditorState;

  factory KnowledgeEditorState.initial() => KnowledgeEditorState(
        bit: KnowledgeBit(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '',
          blocks: const [ContentBlock.text('Enter your notes here...')],
          tags: const [],
          priority: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        saveStatus: SaveStatus.initial,
        isDirty: false,
      );
}
