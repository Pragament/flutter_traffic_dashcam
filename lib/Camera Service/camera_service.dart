import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:camera/camera.dart';
import 'package:car_dashcam/Model/recording_model.dart';
import 'package:hive/hive.dart';

class CameraService {
  late CameraController _controller;
  late String currentRecordingId;
  bool isRecording = false;

  CameraController get controller => _controller;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );
      await _controller.initialize();
    } else {
      throw Exception('No cameras available');
    }
  }

  Future<void> startRecording() async {
    if (_controller.value.isInitialized &&
        !_controller.value.isRecordingVideo) {
      isRecording = true;
      await _controller.startVideoRecording();

      // Start timer to record clips every 30 seconds
      Timer.periodic(const Duration(seconds: 30), (timer) async {
        if (!isRecording) {
          timer.cancel();
        } else {
          await _stopAndStartNewClip();
        }
      });
    }
  }

  Future<void> _stopAndStartNewClip() async {
    if (_controller.value.isRecordingVideo) {
      // Stop the current recording
      final file = await _controller.stopVideoRecording();

      // Generate a unique ID for the recording
      final String newId = const Uuid().v4();

      // Save the video file path and ID to the Hive database
      final recording =
          Recording(id: newId, path: file.path, isFavorite: false);
      Hive.box<Recording>('recordings').add(recording);

      // Update the current recording ID
      currentRecordingId = newId;

      // Start a new recording
      await _controller.startVideoRecording();
    }
  }

  Future<void> stopRecording() async {
    if (_controller.value.isInitialized && _controller.value.isRecordingVideo) {
      isRecording = false;

      await _controller.stopVideoRecording();
    }
  }

  void dispose() {
    _controller.dispose();
  }
}
