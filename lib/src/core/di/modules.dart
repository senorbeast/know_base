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
    return Isar.open(
      [KnowledgeBitModelSchema],
      directory: dir.path,
    );
  }
}
