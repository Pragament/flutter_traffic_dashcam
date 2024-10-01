import 'package:car_dashcam/hive/hive_boxes.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Model/video_model.dart';
import '../Widgets/video_controls.dart';
import '../provider/video_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final cameraControllerAsyncValue = ref.watch(cameraControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dash Cam', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                              final cameraController = ref.read(cameraControllerProvider).value;
                              if(ref.read(settingsProvider).isFavorite){
                                var box = HiveBoxes.getFavVideosBox();
                                box.clear();
                              }else{
                                var box = HiveBoxes.getVideosBox();
                                box.clear();
                              }
                              if (cameraController != null && cameraController.value.isInitialized) {
                                final isRecording = ref.read(recordingStateProvider); // Check recording state

                                try {
                                  if (!isRecording) {
                                    // Start recording multiple clips
                                    ref.read(recordingStateProvider.notifier).state = true; // Update state to recording

                                    List<VideoModel> recordedClips = await ref.read(videoServiceProvider)?.recordMultipleClips(
                                      clipLength: Duration(minutes: ref.read(settingsProvider).clipLength),
                                      clipCount: ref.read(settingsProvider).clipCountLimit,
                                      quality: ref.read(settingsProvider).videoQuality,
                                    ) ?? [];

                                    // Add videos to the respective lists after recording all clips
                                    for (var video in recordedClips) {
                                      if (ref.read(settingsProvider).isFavorite) {
                                        ref.read(favoriteVideoListProvider.notifier).addFavVideo(video, context);
                                      } else {
                                        ref.read(videoListProvider.notifier).addVideo(video, context);
                                      }
                                    }
                                  }

                                  ref.read(recordingStateProvider.notifier).state = false; // Update state to not recording
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: ${e.toString()}')),
                                  );
                                  ref.read(recordingStateProvider.notifier).state = false; // Reset recording state on error
                                }
                              } else {
                                // Handle case when the camera is not initialized or is null
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Camera not initialized')),
                                );
                              }
                            },
                            disabledElevation: 0.0,
                            shape: const CircleBorder(),
                            backgroundColor: ref.watch(recordingStateProvider) ? Colors.black : Colors.white, // Color based on recording state
                            child: Icon(
                              ref.watch(recordingStateProvider) ? Icons.stop : Icons.fiber_manual_record, // Icon based on recording state
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    VideoControls(
                      onSettingsChanged: (int clipLength, int clipCountLimit, ResolutionPreset videoQuality, bool isFavVideo) {
                        // Update the global settingsProvider when settings are changed
                        ref.read(settingsProvider.notifier).updateSettings(clipLength, clipCountLimit, videoQuality);

                        // Update isFavorite state
                        ref.read(settingsProvider.notifier).updateIsFavorite(isFavVideo);
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
        error: (e, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $e'),
              ElevatedButton(
                onPressed: () => ref.refresh(cameraControllerProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),

      ),
    );
  }
}
