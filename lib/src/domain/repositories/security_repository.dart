import 'dart:typed_data';

abstract class ISecurityRepository {
  Future<void> initializeKeys();
  Future<Uint8List> encryptData(Uint8List data);
  Future<Uint8List> decryptData(Uint8List encryptedData);
  Future<String> encryptFile(String filePath, String destinationPath);
  Future<String> decryptFile(String encryptedFilePath, String destinationPath);
}
