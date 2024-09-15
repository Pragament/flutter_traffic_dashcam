import 'dart:async';

import 'package:car_dashcam/Widgets/video_controls.dart';
import 'package:car_dashcam/provider/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final cameraController = ref.watch(cameraControllerProvider).value;
    final isRecording = ref.watch(recordingStateProvider);
    final videoService = ref.read(videoServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dash Cam'),
      ),
      body: cameraController != null && cameraController.value.isInitialized
          ? LayoutBuilder(
        builder: (context, constraints) {
          // Define height for the camera preview based on screen height
          double cameraPreviewHeight = constraints.maxHeight * 0.72;
          double cameraPreviewWidth = constraints.maxWidth * 0.95;

          return Column(
            children: [
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 5)
                    ),
                    width: cameraPreviewWidth,
                    height: cameraPreviewHeight,
                    child: AspectRatio(
                      aspectRatio: cameraController.value.aspectRatio,
                      child: CameraPreview(cameraController),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20.0,
                      bottom: 20.0,
                      top: cameraPreviewHeight * 0.02,
                    ),
                    child: FloatingActionButton(
                      onPressed: () async {
                        if (cameraController.value.isInitialized) {
                          try {
                            if (isRecording) {
                              final video = await videoService?.stopRecording();
                              if (video != null) {
                                ref.read(videoListProvider.notifier).addVideo(video);
                              }
                              ref.read(recordingStateProvider.notifier).state = false;
                            } else {
                              await videoService?.startRecording();
                              ref.read(recordingStateProvider.notifier).state = true;
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Camera not initialized')),
                          );
                        }
                      },
                      disabledElevation: 0.0,
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                      child: Icon(
                        isRecording ? Icons.stop : Icons.fiber_manual_record,
                        color: isRecording ? Colors.black : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              VideoControls(
                onSettingsChanged: (int clipLength, int clipCountLimit, ResolutionPreset videoQuality) {
                  // Handle settings change
                },
              ),
            ],
          );
        },
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
