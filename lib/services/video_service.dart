import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../Model/video_model.dart';

class VideoService {
  final CameraController cameraController;
  final Duration videoLength;
  final int clipCountLimit;
  final ResolutionPreset quality;

  VideoService(this.cameraController, {
    required this.videoLength,
    required this.clipCountLimit,
    required this.quality,
  });


  /// Deletes old clips from both the video box and favorite box.

  Future<void> startRecording() async {
    try {
      await cameraController.startVideoRecording();
    } catch (e) {
      print('Error starting video recording: $e');
      // Consider showing an error message to the user
    }
  }


  Future<VideoModel?> stopRecording() async {
    try {
      XFile videoFile = await cameraController.stopVideoRecording();
      final directory = await getApplicationSupportDirectory();
      String filePath =
          '${directory.path}/CVR_${DateTime
          .now()
          .millisecondsSinceEpoch}.mp4';

      File savedVideo = File(filePath);
      await savedVideo.writeAsBytes(await videoFile.readAsBytes());

      DateTime recordedAt = DateTime.now();
      Duration videoLength = await _getVideoDuration(filePath);

      // Create a video model object
      VideoModel video = VideoModel(
        filePath: filePath,
        recordedAt: recordedAt,
        videoLength: videoLength,
        clipCountLimit: clipCountLimit,
        quality: quality.name,
        isFavorite: false, // Assuming 0 means not favorite by default
      );
      return video;
    } catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<List<VideoModel>> recordMultipleClips({
    required Duration clipLength,
    required int clipCount,
    required ResolutionPreset quality,

  }) async {

    List<VideoModel> recordedClips = [];

    for (int i = 0; i < clipCount; i++) {
      try {
        await startRecording();
        await Future.delayed(clipLength);
        VideoModel? clip = await stopRecording();

        if (clip != null) {
          recordedClips.add(clip);
        } else {
          print('Failed to record clip ${i + 1}');
        }

        if (i + 1 >= clipCount) {
          print('Clip count limit reached. Stopping recording.');
          break;
        }

        // Short delay between recordings, if necessary
        await Future.delayed(const Duration(milliseconds: 500));

      } catch (e) {
        print('Error recording clip ${i + 1}: $e');
        // Stop the recording process in case of error
        break;
      }
    }

    return recordedClips;
  }




  Future<Duration> _getVideoDuration(String filePath) async {
    // Use VideoPlayer to get video duration
    final videoPlayerController = VideoPlayerController.file(File(filePath));
    await videoPlayerController.initialize();
    final duration = videoPlayerController.value.duration;
    videoPlayerController.dispose();
    return duration;
  }

}
