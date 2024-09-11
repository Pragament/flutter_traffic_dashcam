import 'package:hive/hive.dart';

part 'video_model.g.dart';

@HiveType(typeId: 0)
class VideoModel extends HiveObject {
  @HiveField(0)
  final String filePath;

  @HiveField(1)
  final DateTime recordedAt;

  VideoModel({required this.filePath, required this.recordedAt});
}
