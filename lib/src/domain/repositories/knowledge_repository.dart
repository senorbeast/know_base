import '../entities/knowledge_bit.dart';

abstract class IKnowledgeRepository {
  Future<void> createKnowledgeBit(KnowledgeBit bit);
  Future<void> updateKnowledgeBit(KnowledgeBit bit);
  Future<void> deleteKnowledgeBit(String id);
  Future<KnowledgeBit?> getKnowledgeBit(String id);
  Future<List<KnowledgeBit>> getAllKnowledgeBits();
  Future<List<KnowledgeBit>> searchKnowledgeBits(String query, {List<String>? tags});
  Future<KnowledgeBit?> getLastActiveKnowledgeBit();
  Future<void> setLastActiveKnowledgeBit(String id);
  Future<void> clearLastActiveKnowledgeBit();
}
