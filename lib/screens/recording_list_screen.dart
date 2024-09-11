import 'package:car_dashcam/provider/recording_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/recording_list_item.dart';

// Define a StateProvider to manage the 'showFavoritesOnly' state
final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

class RecordingsListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordings = ref.watch(recordingsProvider);
    final showFavoritesOnly = ref
        .watch(showFavoritesOnlyProvider); // Read the 'showFavoritesOnly' state

    final filteredRecordings = showFavoritesOnly
        ? recordings.where((recording) => recording.isFavorite).toList()
        : recordings;

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Recordings'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text("Show Favorites Only"),
            value: showFavoritesOnly,
            onChanged: (value) {
              ref.read(showFavoritesOnlyProvider.notifier).state =
                  value; // Update the 'showFavoritesOnly' state
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRecordings.length,
              itemBuilder: (context, index) {
                return RecordingListItem(recording: filteredRecordings[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
