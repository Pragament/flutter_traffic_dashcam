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

// Video settings provider
final settingsProvider = StateNotifierProvider<VideoSettingsNotifier, VideoSettings>(
      (ref) => VideoSettingsNotifier(),
);

class VideoSettings {
  final int clipLength;
  final int clipCountLimit;
  final ResolutionPreset videoQuality;

  VideoSettings({
    required this.clipLength,
    required this.clipCountLimit,
    required this.videoQuality,
  });
}

class VideoSettingsNotifier extends StateNotifier<VideoSettings> {
  VideoSettingsNotifier() : super(
    VideoSettings(
      clipLength: defaultClipLength,
      clipCountLimit: defaultClipCountLimit,
      videoQuality: defaultVideoQuality,
    ),
  );

  void updateSettings(int clipLength, int clipCountLimit, ResolutionPreset videoQuality) {
    state = VideoSettings(
      clipLength: clipLength,
      clipCountLimit: clipCountLimit,
      videoQuality: videoQuality,
    );
  }
}

const defaultClipLength = 1; // 1 minute
const defaultClipCountLimit = 10; // 10 clips
const defaultVideoQuality = ResolutionPreset.medium;

final videoServiceProvider = Provider<VideoService?>((ref) {
  final cameraControllerAsync = ref.watch(cameraControllerProvider);
  final settings = ref.watch(settingsProvider);

  return cameraControllerAsync.when(
    data: (cameraController) {
      if (cameraController != null) {
        return VideoService(
          cameraController,
          videoLength: Duration(minutes: settings.clipLength),
          clipCountLimit: settings.clipCountLimit,
          quality: settings.videoQuality,
        );
      } else {
        return null;
      }
    },
    loading: () => null,
    error: (error, stackTrace) {
      print('Error creating video service: $error');
      return null;
    },
  );
});

// Recording state provider
final recordingStateProvider = StateProvider<bool>((ref) => false);

// Video list provider
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
}
