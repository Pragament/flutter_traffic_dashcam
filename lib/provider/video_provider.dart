import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../Model/video_model.dart';
import '../services/video_service.dart';

// Camera controller provider
final cameraControllerProvider = FutureProvider<CameraController?>((ref) async {
  try {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final cameraController = CameraController(cameras[0], ResolutionPreset.high);
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
final videoServiceProvider = Provider<VideoService?>((ref) {
  final cameraControllerAsyncValue = ref.watch(cameraControllerProvider);

  // Handle different states of the camera controller provider
  return cameraControllerAsyncValue.when(
    data: (cameraController) {
      if (cameraController != null && cameraController.value.isInitialized) {
        return VideoService(cameraController);
      } else {
        return null; // Return null if the camera is not initialized
      }
    },
    loading: () => null, // Return null while loading
    error: (e, stackTrace) {
      print('Error creating video service: $e');
      return null; // Return null if there was an error
    },
  );
});

// Recording state provider
final recordingStateProvider = StateProvider<bool>((ref) => false);

// Video list provider to manage saved videos
final videoListProvider = StateNotifierProvider<VideoListNotifier, List<VideoModel>>(
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

