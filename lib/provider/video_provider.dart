import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../Model/video_model.dart';
import '../hive/hive_boxes.dart';
import '../services/video_service.dart';

// Camera controller provider
final cameraControllerProvider = FutureProvider<CameraController?>((ref) async {
  try {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await cameraController.initialize();
      return cameraController;
    } else {
      throw Exception("No available cameras found");
    }
  } catch (e) {
    print('Error initializing camera: $e');
    return null;
  }
});

const defaultClipLength = 1; // 1 minute
const defaultClipCountLimit = 10; // 10 clips
const defaultVideoQuality = ResolutionPreset.medium;


final videoServiceProvider = Provider<VideoService?>((ref) {
  final cameraControllerAsyncValue = ref.watch(cameraControllerProvider);
  return cameraControllerAsyncValue.when(
    data: (cameraController) {
      if (cameraController != null && cameraController.value.isInitialized) {
        return VideoService(
          cameraController,
          videoLength: defaultClipLength,
          clipCountLimit: defaultClipCountLimit,
          quality: defaultVideoQuality,
        );
      } else {
        return null;
      }
    },
    loading: () => null,
    error: (e, stackTrace) {
      print('Error creating video service: $e');
      return null;
    },
  );
});

// Recording state provider
final recordingStateProvider = StateProvider<bool>((ref) => false);

final videoListProvider = StateNotifierProvider<VideoListNotifier, List<VideoModel>>(
      (ref) => VideoListNotifier(),
);


class VideoListNotifier extends StateNotifier<List<VideoModel>> {
  VideoListNotifier() : super([]) {
    loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      var box = HiveBoxes.getVideosBox();
      final videos = box.values.toList();
      state = videos;
      print('Videos loaded: ${state.length}');
    } catch (e, stackTrace) {
      print('Error loading videos: $e');
      print('Stack trace: $stackTrace');
    }
  }


  void addVideo(VideoModel video) async {
    try {
      var box = HiveBoxes.getVideosBox();
      await box.add(video); // Ensure video is added to the Hive box
      state = [...state, video];
      print('Video added successfully.');
    } catch (e) {
      print('Error adding video: $e');
    }
  }


// void loadVideos(List<VideoModel> videos) {
//   state = videos;
// }
}