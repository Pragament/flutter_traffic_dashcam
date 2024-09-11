import 'package:car_dashcam/Model/recording_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final recordingsProvider =
    StateNotifierProvider<RecordingsNotifier, List<Recording>>((ref) {
  return RecordingsNotifier();
});

class RecordingsNotifier extends StateNotifier<List<Recording>> {
  RecordingsNotifier()
      : super(Hive.box<Recording>('recordings').values.toList());

  void addRecording(Recording recording) {
    state = [...state, recording];
    Hive.box<Recording>('recordings').add(recording);
  }

  void toggleFavorite(String id) {
    final index = state.indexWhere((rec) => rec.id == id);
    if (index != -1) {
      final updatedRecording =
          state[index].copyWith(isFavorite: !state[index].isFavorite);
      state[index] = updatedRecording;
      Hive.box<Recording>('recordings').putAt(index, updatedRecording);
    }
  }
}
