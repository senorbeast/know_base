import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../domain/repositories/security_repository.dart';

@lazySingleton
class MediaService {
  final ISecurityRepository _securityRepository;
  final ImagePicker _picker = ImagePicker();

  MediaService(this._securityRepository);

  Future<String?> pickAndEncryptImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.enc';
    final destinationPath = p.join(dir.path, fileName);

    return await _securityRepository.encryptFile(image.path, destinationPath);
  }

  Future<Map<String, String>?> pickAndEncryptFile() async {
    final fp.FilePickerResult? result = await fp.FilePicker.pickFiles();
    if (result == null || result.files.single.path == null) return null;

    final file = result.files.single;
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.enc';
    final destinationPath = p.join(dir.path, fileName);

    final encryptedPath = await _securityRepository.encryptFile(file.path!, destinationPath);
    return {
      'path': encryptedPath,
      'name': file.name,
    };
  }
}
