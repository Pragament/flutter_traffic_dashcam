import 'package:hive/hive.dart';

part 'recording_model.g.dart';

@HiveType(typeId: 0)
class Recording {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String path;
  @HiveField(2)
  final bool isFavorite;

  Recording({required this.id, required this.path, this.isFavorite = false});

  Recording copyWith({bool? isFavorite}) {
    return Recording(
      id: id,
      path: path,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
