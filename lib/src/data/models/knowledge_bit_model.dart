import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/entities/content_block.dart';
import '../../domain/entities/knowledge_bit.dart';

part 'knowledge_bit_model.g.dart';

@collection
class KnowledgeBitModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  late String title;

  late List<String> blocksJson;

  late List<String> tags;

  @Index()
  String? category;

  @Index()
  int? priority;

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  @Index()
  bool isLastActive = false;

  // For composite indexes as requested
  @Index(composite: [CompositeIndex('priority'), CompositeIndex('createdAt')])
  DateTime get datePriorityIndex => createdAt;
}

extension KnowledgeBitModelX on KnowledgeBitModel {
  KnowledgeBit toEntity() {
    return KnowledgeBit(
      id: remoteId,
      title: title,
      blocks: blocksJson
          .map((json) => ContentBlock.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList(),
      tags: tags,
      category: category,
      priority: priority,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static KnowledgeBitModel fromEntity(KnowledgeBit entity) {
    return KnowledgeBitModel()
      ..remoteId = entity.id
      ..title = entity.title
      ..blocksJson = entity.blocks.map((block) => jsonEncode(block.toJson())).toList()
      ..tags = entity.tags
      ..category = entity.category
      ..priority = entity.priority
      ..createdAt = entity.createdAt ?? DateTime.now()
      ..updatedAt = entity.updatedAt ?? DateTime.now();
  }
}
