import 'package:freezed_annotation/freezed_annotation.dart';
import 'content_block.dart';

part 'knowledge_bit.freezed.dart';
part 'knowledge_bit.g.dart';

@freezed
class KnowledgeBit with _$KnowledgeBit {
  const factory KnowledgeBit({
    required String id,
    required String title,
    @Default([]) List<ContentBlock> blocks,
    @Default([]) List<String> tags,
    String? category,
    int? priority,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
  }) = _KnowledgeBit;

  factory KnowledgeBit.fromJson(Map<String, dynamic> json) => _$KnowledgeBitFromJson(json);
}
