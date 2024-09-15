import 'package:car_dashcam/provider/video_provider.dart';
import 'package:car_dashcam/screens/videoplayer/videoscreenplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecordinglistScreen extends ConsumerStatefulWidget {
  const RecordinglistScreen({super.key});

  @override
  _RecordinglistScreenState createState() => _RecordinglistScreenState();
}

class _RecordinglistScreenState extends ConsumerState<RecordinglistScreen> {


  @override
  Widget build(BuildContext context) {
    final videoList = ref.watch(videoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording List'),
      ),
      body: videoList.isEmpty
          ? const Center(child: Text('No recordings available'))
          : ListView.builder(
        itemCount: videoList.length,
        itemBuilder: (BuildContext context, index) {
          final video = videoList[index];

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                // context.go('/video_player', extra: video.filePath);
                Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(filePath: video.filePath)));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      height: 220.0,
                      width: double.infinity,
                      child: ColoredBox(color: Colors.black),
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_circle_outline_sharp,
                          color: Colors.blue, size: 48.0),
                      onPressed: () {
                        // This is now handled by GestureDetector's onTap
                      },
                    ),
                    Positioned(
                      bottom: 8.0,
                      left: 8.0,
                      child: Text(
                        formatDate(video.recordedAt),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
