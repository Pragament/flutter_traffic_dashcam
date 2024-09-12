import 'package:car_dashcam/Widgets/video_controls.dart';
import 'package:car_dashcam/provider/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/video_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late CameraController _cameraController;
  late VideoService videoService;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController.initialize();
    videoService = VideoService(_cameraController);
    // ref.read(videoServiceProvider.notifire).state = videoService; // Update the videoService provider
    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = ref.watch(cameraControllerProvider).value;
    final isRecording = ref.watch(recordingStateProvider);
    final videoService = ref.watch(videoServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dash Cam'),
      ),
      body: cameraController != null && cameraController.value.isInitialized
          ? Column(
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: AspectRatio(
                        aspectRatio: cameraController.value.aspectRatio,
                        child: CameraPreview(cameraController),
                      ),// Display the camera preview
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, bottom: 20.0, top: 5.0),
                      child: FloatingActionButton(
                        onPressed: () async
                        {
                          if (cameraController.value.isInitialized) {
                            try {
                              if (isRecording) {
                                final videoService = ref.read(videoServiceProvider);
                                if (videoService != null) {
                                  final video = await videoService.stopRecording();
                                  if (video != null) {
                                    ref.read(videoListProvider.notifier).addVideo(video);
                                  }
                                  ref.read(recordingStateProvider.notifier).state = false;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Video service not initialized')),
                                  );
                                }
                              } else {
                                final videoService = ref.read(videoServiceProvider);
                                if (videoService != null) {
                                  await videoService.startRecording();
                                  ref.read(recordingStateProvider.notifier).state = true;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Video service not initialized')),
                                  );
                                }
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
                const SizedBox(height: 10.0,),
                const VideoControls(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
