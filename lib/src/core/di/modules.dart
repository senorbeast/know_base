import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/knowledge_bit_model.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @preResolve
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    Isar? isarInstance;
    try {
      isarInstance = await Isar.open(
        [KnowledgeBitModelSchema],
        directory: dir.path,
      );
      // Verify schema compatibility by executing a quick query.
      // This will throw a RangeError if the schema has changed and is incompatible.
      await isarInstance.knowledgeBitModels.where().findAll();
      return isarInstance;
    } catch (e) {
      // Schema mismatch or data corruption detected.
      // Clean up the corrupted/mismatched database and reinitialize.
      if (isarInstance != null) {
        await isarInstance.close(deleteFromDisk: true);
      } else {
        final existing = Isar.getInstance();
        if (existing != null) {
          await existing.close(deleteFromDisk: true);
        } else {
          final isarDir = Directory(dir.path);
          if (await isarDir.exists()) {
            await for (final file in isarDir.list()) {
              if (file.path.endsWith('.isar')) {
                try {
                  await file.delete();
                } catch (_) {}
              }
            }
          }
        }
      }
      return Isar.open(
        [KnowledgeBitModelSchema],
        directory: dir.path,
      );
    }
  }
}
