import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Import path_provider
import '../Model/video_model.dart';
import '../hive/hive_boxes.dart';

class VideoService {
  final CameraController cameraController;

  VideoService(this.cameraController);

  Future<void> startRecording() async {
    try {
      await cameraController.startVideoRecording();
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<VideoModel?> stopRecording() async {
    try {
      XFile videoFile = await cameraController.stopVideoRecording();

      // Get the directory to save the video
      final directory = await getApplicationSupportDirectory();
      String filePath =
          '${directory.path}/CVR_${DateTime.now().millisecondsSinceEpoch}.mp4';

      debugPrint(filePath);

      // Save the video to the determined file path
      File savedVideo = File(filePath);
      await savedVideo.writeAsBytes(await videoFile.readAsBytes());

      DateTime recordedAt = DateTime.now();
      VideoModel video = VideoModel(filePath: filePath, recordedAt: recordedAt);

      // Save the video metadata to Hive
      HiveBoxes.getVideosBox().add(video);

      return video;
    } catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }
}
