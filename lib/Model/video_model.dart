import 'package:hive/hive.dart';
import '../enum/enum.dart';

part 'video_model.g.dart';

@HiveType(typeId: 0)
class VideoModel extends HiveObject {
  @HiveField(0)
  final String filePath;

  @HiveField(1)
  final DateTime recordedAt;

  @HiveField(2)
  final Duration videoLength;

  @HiveField(3)
  final int clipCountLimit;

  @HiveField(4)
    final String quality;

  @HiveField(5)
  bool isFavorite;

  VideoModel({
    required this.filePath,
    required this.recordedAt,
    required this.videoLength,
    required this.clipCountLimit,
    required this.quality,
    this.isFavorite = false,
  });
}

