import 'package:flutter/material.dart';
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
  final bool isFavorite;

  VideoSettings({
    required this.clipLength,
    required this.clipCountLimit,
    required this.videoQuality,
    this.isFavorite = false, // Default to false if not provided
  });
}


class VideoSettingsNotifier extends StateNotifier<VideoSettings> {
  VideoSettingsNotifier()
      : super(
    VideoSettings(
      clipLength: 1,
      clipCountLimit: 10,
      videoQuality: ResolutionPreset.medium,
      isFavorite: false, // Initial favorite state
    ),
  );

  // Method to update video settings including isFavorite
  void updateSettings(int clipLength, int clipCountLimit, ResolutionPreset videoQuality, {bool isFavorite = false}) {
    state = VideoSettings(
      clipLength: clipLength,
      clipCountLimit: clipCountLimit,
      videoQuality: videoQuality,
      isFavorite: isFavorite,
    );
  }

  // Optional method to update only the favorite status
  void updateIsFavorite(bool isFavorite) {
    state = VideoSettings(
      clipLength: state.clipLength,
      clipCountLimit: state.clipCountLimit,
      videoQuality: state.videoQuality,
      isFavorite: isFavorite,
    );
  }
}


// VideoService provider
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

  // Future<void> loadVideos() async {
  //   try {
  //     var box = HiveBoxes.getVideosBox();
  //     final videoDataList = box.get('videos') as List<dynamic>; // Get the raw list
  //
  //     // Convert the raw data back to a list of VideoModel
  //     state = videoDataList.map((data) => VideoModel.fromJson(data)).toList();
  //     print('Videos loaded: ${state.length}');
  //   } catch (e) {
  //     print('Error loading videos: $e');
  //   }
  // }
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


  void addVideo(VideoModel video, BuildContext context) async {
    try {
      var box = HiveBoxes.getVideosBox();

      await box.put(video.filePath,video); // Use put to replace the video
      state = [...state, video]; // Replace the state with the new list
      print('Video added/updated successfully. ${video.filePath}');

    } catch (e) {
      print('Error adding/updating video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add/update video: $e')),
      );
    }
  }

  // void addVideo(VideoModel video, BuildContext context) async {
  //   try {
  //     var box = HiveBoxes.getVideosBox();
  //
  //     // Normalize the file path for comparison
  //     final normalizedFilePath = normalizeFilePath(video.filePath);
  //
  //     // Check if the video already exists
  //     final existingVideos = state.where((v) => normalizeFilePath(v.filePath) == normalizedFilePath).toList();
  //
  //     if (existingVideos.isNotEmpty) {
  //       // If it exists, remove the old video from the box
  //       await box.delete(existingVideos.first.key); // Use the key to delete
  //
  //       // Update the state to remove the existing video
  //       state = state.where((v) => v.filePath != video.filePath).toList();
  //       print('Removed existing video: ${existingVideos.first.filePath}');
  //     }
  //
  //     await box.put(video.key, video); // Use put for updating or adding
  //     state = [...state, video];
  //
  //     print('Video added/updated successfully.');
  //   } catch (e) {
  //     print('Error adding/updating video: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to add/update video: $e')),
  //     );
  //   }
  // }
  // void addVideo(VideoModel videos, BuildContext context) async {
  //   try {
  //     var box = HiveBoxes.getVideosBox();
  //
  //     // Clear the existing videos in the Hive box
  //     await box.clear(); // This will delete all existing entries
  //
  //     for (var video in videos) {
  //       await box.put(video.filePath, video); // Use the file path as the key
  //     }
  //     state = videos; // Update state with the new video list
  //
  //
  //     print('All existing videos deleted and new video added successfully.');
  //   } catch (e) {
  //     print('Error adding video: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to add video: $e')),
  //     );
  //   }
  // }

  String normalizeFilePath(String filePath) {
    return filePath.toLowerCase().trim();
  }
}

// Favorite video list provider
final favoriteVideoListProvider = StateNotifierProvider<FavoriteVideoListNotifier, List<VideoModel>>(
      (ref) => FavoriteVideoListNotifier(),
);

class FavoriteVideoListNotifier extends StateNotifier<List<VideoModel>> {
  FavoriteVideoListNotifier() : super([]) {
    loadFavoriteVideos();
  }

  void addFavVideo(VideoModel video, BuildContext context) async {
    try {
      var box = HiveBoxes.getFavVideosBox();

      await box.put(video.filePath,video); // Use put to replace the video
      state = [...state, video]; // Replace the state with the new list
      print('Favorite video added/updated successfully.');

    } catch (e) {
      print('Error adding/updating favorite video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add/update favorite video: $e')),
      );
    }
  }
  // void addFavVideo(VideoModel video, BuildContext context) async {
  //   try {
  //     var box = HiveBoxes.getFavVideosBox();
  //
  //     // Normalize file path
  //     final normalizedFilePath = normalizeFilePath(video.filePath);
  //
  //     // Check if the favorite video already exists
  //     final existingFavorites = state.where((v) => normalizeFilePath(v.filePath) == normalizedFilePath).toList();
  //
  //     if (existingFavorites.isNotEmpty) {
  //       // If it exists, remove the old favorite video
  //       await box.delete(existingFavorites.first.filePath); // Use the key, not the filePath
  //       state = state.where((v) => v.filePath != video.filePath).toList();
  //       print('Removed existing favorite video: ${existingFavorites.first.filePath}');
  //     }
  //
  //     // Add the new or updated favorite video
  //     await box.add(video); // Use put for updating or adding
  //     state = [...state, video]; // Replace the list with the new one
  //
  //     print('Favorite video added/updated successfully: ${video.filePath}');
  //
  //   } catch (e) {
  //     print('Error adding/updating favorite video: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to add/update favorite video: $e')),
  //     );
  //   }
  // }



  // Future<void> loadFavoriteVideos() async {
  //     try {
  //       var box = HiveBoxes.getVideosBox();
  //       final videoDataList = box.get('favoriteVideos') as List<dynamic>; // Get the raw list
  //
  //       // Convert the raw data back to a list of VideoModel
  //       state = videoDataList.map((data) => VideoModel.fromJson(data)).toList();
  //       print('Videos loaded: ${state.length}');
  //     } catch (e) {
  //       print('Error loading videos: $e');
  //     }
  //
  // }

  // void addFavVideo(VideoModel video, BuildContext context) async {
  //   try {
  //     var box = HiveBoxes.getFavVideosBox();
  //
  //     // Clear existing favorite videos in the Hive box
  //     await box.clear(); // This will delete all existing favorites
  //
  //     // Now add the new favorite video
  //     await box.put(video.filePath, video); // Use the file path as the key
  //     state = [video]; // Update state with the new favorite video
  //
  //     print('All existing favorite videos deleted and new favorite video added successfully.');
  //   } catch (e) {
  //     print('Error adding favorite video: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to add favorite video: $e')),
  //     );
  //   }
  // }


  Future<void> loadFavoriteVideos() async {
    try {
      var box = HiveBoxes.getFavVideosBox();
      final videos = box.values.toList();
      state = videos;
      print('Videos loaded: ${state.length}');
    } catch (e, stackTrace) {
      print('Error loading videos: $e');
      print('Stack trace: $stackTrace');
    }
  }


  String normalizeFilePath(String filePath) {
    return filePath.toLowerCase().trim();
  }
}
