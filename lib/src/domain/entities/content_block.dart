import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_block.freezed.dart';
part 'content_block.g.dart';

@freezed
class ContentBlock with _$ContentBlock {
  const factory ContentBlock.text(String data) = TextContentBlock;
  const factory ContentBlock.image({
    required String encryptedPath,
    String? caption,
  }) = ImageContentBlock;
  const factory ContentBlock.file({
    required String encryptedPath,
    required String fileName,
  }) = FileContentBlock;

  factory ContentBlock.fromJson(Map<String, dynamic> json) => _$ContentBlockFromJson(json);
}
