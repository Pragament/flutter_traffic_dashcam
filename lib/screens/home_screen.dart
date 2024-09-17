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
    final cameraControllerAsyncValue = ref.watch(cameraControllerProvider);
    final videoService = ref.watch(videoServiceProvider);

    // Define the clip settings
    int clipLength = 1; // in minutes
    int clipCountLimit = 5;
    ResolutionPreset videoQuality = ResolutionPreset.medium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dash Cam',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: cameraControllerAsyncValue.when(
        data: (cameraController) {
          if (cameraController != null && cameraController.value.isInitialized) {
            return LayoutBuilder(
              builder: (context, constraints) {
                double cameraPreviewHeight = constraints.maxHeight * 0.72;
                double cameraPreviewWidth = constraints.maxWidth * 1;

                return Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        SizedBox(
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
                                final isRecording = ref.read(recordingStateProvider); // Check recording state

                                try {
                                  if (isRecording) {
                                    // If already recording, stop the recording
                                    final video = await videoService?.stopRecording();
                                    if (video != null) {
                                      ref.read(videoListProvider.notifier).addVideo(video);
                                    }
                                    ref.read(recordingStateProvider.notifier).state = false; // Update state to not recording
                                  } else {
                                    // Start recording multiple clips
                                    ref.read(recordingStateProvider.notifier).state = true; // Update state to recording
                                    await videoService?.recordMultipleClips(
                                      clipLength: Duration(minutes: clipLength), // Clip length from text field
                                      clipCount: clipCountLimit, // Clip count from text field
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: ${e.toString()}')),
                                  );
                                  ref.read(recordingStateProvider.notifier).state = false; // Reset recording state on error
                                }
                              } else {
                                // Handle case when the camera is not initialized
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Camera not initialized')),
                                );
                              }
                            },
                            disabledElevation: 0.0,
                            shape: const CircleBorder(),
                            backgroundColor: ref.watch(recordingStateProvider) ? Colors.black : Colors.red, // Color based on recording state
                            child: Icon(
                              ref.watch(recordingStateProvider) ? Icons.stop : Icons.fiber_manual_record, // Icon based on recording state
                              color: Colors.white,
                            ),
                          ),

                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    VideoControls(
                      onSettingsChanged: (int CL, int CCL, ResolutionPreset VD) {
                        // Handle settings change
                        setState(() {
                          clipLength = CL;
                          clipCountLimit = CCL;
                          videoQuality = VD;
                        });

                        ref.refresh(videoServiceProvider);
                        // If you want to update VideoService settings, you might need to create a new VideoService instance or update accordingly
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stackTrace) => Center(child: Text('Error: $e')),
      ),
    );
  }
}


