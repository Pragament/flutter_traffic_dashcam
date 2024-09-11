import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../Model/video_model.dart';
import '../services/video_service.dart';

// Camera controller provider
final cameraControllerProvider = FutureProvider<CameraController?>((ref) async {
  try {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final cameraController =
          CameraController(cameras[0], ResolutionPreset.high);
      await cameraController.initialize(); // Ensure the camera is initialized
      return cameraController;
    } else {
      throw Exception("No available cameras found");
    }
  } catch (e) {
    print('Error initializing camera: $e');
    return null; // Return null if initialization fails
  }
});

// Video service provider that depends on the camera controller
final videoServiceProvider = Provider<VideoService>((ref) {
  final cameraController = ref.watch(cameraControllerProvider).value;
  if (cameraController != null && cameraController.value.isInitialized) {
    return VideoService(cameraController);
  } else {
    throw Exception("CameraController not initialized.");
  }
});

// Recording state provider
final recordingStateProvider = StateProvider<bool>((ref) => false);

// Video list provider to manage saved videos
final videoListProvider =
    StateNotifierProvider<VideoListNotifier, List<VideoModel>>(
  (ref) => VideoListNotifier(),
);

class VideoListNotifier extends StateNotifier<List<VideoModel>> {
  VideoListNotifier() : super([]);

  void addVideo(VideoModel video) {
    state = [...state, video];
  }

  void loadVideos(List<VideoModel> videos) {
    state = videos;
  }
}
