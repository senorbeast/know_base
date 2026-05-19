part of 'knowledge_editor_bloc.dart';

@freezed
class KnowledgeEditorEvent with _$KnowledgeEditorEvent {
  const factory KnowledgeEditorEvent.initialize({KnowledgeBit? existingBit}) = _Initialize;
  const factory KnowledgeEditorEvent.titleChanged(String title) = _TitleChanged;
  const factory KnowledgeEditorEvent.blockAdded(ContentBlock block) = _BlockAdded;
  const factory KnowledgeEditorEvent.blockUpdated(int index, ContentBlock block) = _BlockUpdated;
  const factory KnowledgeEditorEvent.tagsChanged(List<String> tags) = _TagsChanged;
  const factory KnowledgeEditorEvent.priorityChanged(int? priority) = _PriorityChanged;
  const factory KnowledgeEditorEvent.autoSave() = _AutoSave;
  const factory KnowledgeEditorEvent.reset() = _Reset;
}
