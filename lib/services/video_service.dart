import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Import path_prov
import 'package:video_player/video_player.dart';
import '../Model/video_model.dart';
import '../enum/enum.dart';

class VideoService {
  final CameraController cameraController;

  VideoService(this.cameraController,
      {required int videoLength,
        required int clipCountLimit,
        required ResolutionPreset quality});

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

      // Get the directory to save the video
      final directory = await getApplicationSupportDirectory();
      String filePath =
          '${directory.path}/CVR_${DateTime.now().millisecondsSinceEpoch}.mp4';

      debugPrint('Saving video to: $filePath');

      // Save the video to the determined file path
      File savedVideo = File(filePath);
      await savedVideo.writeAsBytes(await videoFile.readAsBytes());

      DateTime recordedAt = DateTime.now();

      Duration videoLength = await _getVideoDuration(filePath);

      VideoModel video = VideoModel(
        filePath: filePath,
        recordedAt: recordedAt,
        videoLength: videoLength, // Placeholder for video length
        clipCountLimit: 0, // Placeholder for clip count limit
        quality: VideoQuality.high.name, // Placeholder for video quality
      );

      return video;
    } catch (e) {
      print('Error stopping video recording: $e');
      // Consider showing an error message to the user
      return null;
    }
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