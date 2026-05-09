part of 'knowledge_editor_bloc.dart';

@freezed
class KnowledgeEditorState with _$KnowledgeEditorState {
  const factory KnowledgeEditorState.initial() = _Initial;
  const factory KnowledgeEditorState.saving() = _Saving;
  const factory KnowledgeEditorState.success() = _Success;
  const factory KnowledgeEditorState.failure(String message) = _Failure;
}
