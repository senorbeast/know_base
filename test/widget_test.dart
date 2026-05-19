import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:cerebro/main.dart';
import 'package:cerebro/src/core/di/injection.dart';
import 'package:cerebro/src/domain/entities/content_block.dart';
import 'package:cerebro/src/domain/entities/knowledge_bit.dart';
import 'package:cerebro/src/domain/repositories/knowledge_repository.dart';
import 'package:cerebro/src/features/editor/presentation/bloc/knowledge_editor_bloc.dart';
import 'package:cerebro/src/features/search/presentation/bloc/search_bloc.dart';
import 'package:cerebro/src/features/vault/presentation/bloc/vault_bloc.dart';

class FakeKnowledgeRepository implements IKnowledgeRepository {
  final List<KnowledgeBit> bits = [];

  @override
  Future<void> createKnowledgeBit(KnowledgeBit bit) async {
    bits.add(bit);
  }

  @override
  Future<void> updateKnowledgeBit(KnowledgeBit bit) async {
    final idx = bits.indexWhere((b) => b.id == bit.id);
    if (idx != -1) {
      bits[idx] = bit;
    }
  }

  @override
  Future<void> deleteKnowledgeBit(String id) async {
    bits.removeWhere((b) => b.id == id);
  }

  @override
  Future<KnowledgeBit?> getKnowledgeBit(String id) async {
    return bits.firstWhere((b) => b.id == id);
  }

  @override
  Future<List<KnowledgeBit>> getAllKnowledgeBits() async {
    return bits;
  }

  @override
  Future<List<KnowledgeBit>> searchKnowledgeBits(String query, {List<String>? tags}) async {
    return bits;
  }

  @override
  Future<KnowledgeBit?> getLastActiveKnowledgeBit() async {
    return null;
  }

  @override
  Future<void> setLastActiveKnowledgeBit(String id) async {}

  @override
  Future<void> clearLastActiveKnowledgeBit() async {}
}

void main() {
  late FakeKnowledgeRepository repo;

  setUp(() {
    getIt.reset();
    repo = FakeKnowledgeRepository();
    getIt.registerSingleton<IKnowledgeRepository>(repo);
    getIt.registerFactory<KnowledgeEditorBloc>(() => KnowledgeEditorBloc(repo));
    getIt.registerFactory<SearchBloc>(() => SearchBloc(repo));
    getIt.registerFactory<VaultBloc>(() => VaultBloc(repo));
  });

  testWidgets('Navigate to Vault page test with loaded bits', (WidgetTester tester) async {
    // Add a mock knowledge bit to the repository
    repo.bits.add(KnowledgeBit(
      id: '1',
      title: 'Mock Title',
      blocks: const [ContentBlock.text('Content')],
      tags: const ['Tag1', 'Tag2'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify we are on Editor page initially
    expect(find.text('Cerebro Editor'), findsOneWidget);

    // Find and tap the Vault tab in bottom navigation
    final vaultTab = find.byIcon(Icons.storage);
    expect(vaultTab, findsOneWidget);
    await tester.tap(vaultTab);
    await tester.pumpAndSettle();

    // Verify we navigated to Knowledge Vault
    expect(find.text('Knowledge Vault'), findsOneWidget);
  });
}
