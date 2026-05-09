import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/knowledge_bit.dart';
import '../../domain/repositories/knowledge_repository.dart';
import '../models/knowledge_bit_model.dart';

@LazySingleton(as: IKnowledgeRepository)
class KnowledgeRepositoryImpl implements IKnowledgeRepository {
  final Isar _isar;

  KnowledgeRepositoryImpl(this._isar);

  @override
  Future<void> createKnowledgeBit(KnowledgeBit bit) async {
    final model = KnowledgeBitModelX.fromEntity(bit);
    await _isar.writeTxn(() async {
      await _isar.knowledgeBitModels.put(model);
    });
  }

  @override
  Future<void> updateKnowledgeBit(KnowledgeBit bit) async {
    final existing = await _isar.knowledgeBitModels.filter().remoteIdEqualTo(bit.id).findFirst();
    final model = KnowledgeBitModelX.fromEntity(bit);
    if (existing != null) {
      model.id = existing.id;
    }
    await _isar.writeTxn(() async {
      await _isar.knowledgeBitModels.put(model);
    });
  }

  @override
  Future<void> deleteKnowledgeBit(String id) async {
    await _isar.writeTxn(() async {
      await _isar.knowledgeBitModels.filter().remoteIdEqualTo(id).deleteFirst();
    });
  }

  @override
  Future<KnowledgeBit?> getKnowledgeBit(String id) async {
    final model = await _isar.knowledgeBitModels.filter().remoteIdEqualTo(id).findFirst();
    return model?.toEntity();
  }

  @override
  Future<List<KnowledgeBit>> getAllKnowledgeBits() async {
    final models = await _isar.knowledgeBitModels.where().findAll();
    return models.map((m) => m.toEntity()).toList();
  }
  @override
  Future<List<KnowledgeBit>> searchKnowledgeBits(String query, {List<String>? tags}) async {
    var queryBuilder = _isar.knowledgeBitModels.filter().titleContains(query, caseSensitive: false);

    if (tags != null && tags.isNotEmpty) {
      for (final tag in tags) {
        queryBuilder = queryBuilder.tagsElementContains(tag);
      }
    }

    final models = await queryBuilder.findAll();
    return models.map((m) => m.toEntity()).toList();
  }
}
