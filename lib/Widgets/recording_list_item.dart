import 'package:car_dashcam/Model/recording_model.dart';
import 'package:car_dashcam/provider/recording_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordingListItem extends ConsumerWidget {
  final Recording recording;

  RecordingListItem({required this.recording});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(recording.path.split('/').last),
      trailing: IconButton(
        icon:
            Icon(recording.isFavorite ? Icons.favorite : Icons.favorite_border),
        onPressed: () {
          ref.read(recordingsProvider.notifier).toggleFavorite(recording.id);
        },
      ),
    );
  }
}
