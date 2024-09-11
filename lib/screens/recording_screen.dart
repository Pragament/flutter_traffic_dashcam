import 'package:camera/camera.dart';
import 'package:car_dashcam/Camera%20Service/camera_service.dart';
import 'package:car_dashcam/provider/recording_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecordingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraService = CameraService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashcam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              context.go('/recordings');
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: cameraService.initializeCamera(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    height: 580.0,
                    width: double.infinity, // Use double.infinity instead of double.maxFinite for width
                    child: CameraPreview(cameraService.controller),
                  ),
                ),
                // FloatingActionButton(
                //   onPressed: () {
                //     ref
                //         .read(recordingsProvider.notifier)
                //         .toggleFavorite(cameraService.currentRecordingId);
                //   },
                //   child: Icon(Icons.favorite),
                // ),
                SizedBox(height: 60.0),
                Transform.rotate(
                  angle: 3.14 / 2, // 90 degrees in radians
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, // Removed the extra dot
                    children: [
                      Text(
                        "Current Video Started at 15.03",
                        style: TextStyle(fontSize: 16.0), // Increased font size for better readability
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     cameraService.startRecording();
      //   },
      //   child: Icon(Icons.videocam),
      // ),
    );
  }
}
