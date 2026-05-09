part of 'knowledge_editor_bloc.dart';

@freezed
class KnowledgeEditorEvent with _$KnowledgeEditorEvent {
  const factory KnowledgeEditorEvent.titleChanged(String title) = _TitleChanged;
  const factory KnowledgeEditorEvent.blocksChanged(List<ContentBlock> blocks) = _BlocksChanged;
  const factory KnowledgeEditorEvent.saveRequested(KnowledgeBit bit) = _SaveRequested;
}
