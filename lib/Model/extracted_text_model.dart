import 'package:hive/hive.dart';

part 'extracted_text_model.g.dart';

@HiveType(typeId: 2)
class ExtractedTextModel extends HiveObject {
  @HiveField(0)
  final String videoPath;

  @HiveField(1)
  final List<Map<int, String>> text;

  ExtractedTextModel({
    required this.videoPath,
    required this.text,
  });
}
