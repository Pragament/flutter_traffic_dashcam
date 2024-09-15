import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String filePath;


  const VideoPlayerScreen({super.key, required this.filePath});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {

  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Lock orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    // Reset orientation to default
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                // aspectRatio: _controller.value.playbackSpeed,
                aspectRatio: 16/9,
                child: VideoPlayer(_controller),
              )
                  : const CircularProgressIndicator(),
            ),
         Center(
           child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (_isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                      _isPlaying = !_isPlaying;
                    });
                  },
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  size: 80, // Increase the size of the icon
                  color: _isPlaying ? Colors.blue : Colors.white, // Different colors for play and pause
                ),
              ),
         ),
          
          Positioned(
            bottom: 30,
            left: 62,
            right: 62  ,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                  backgroundColor: Color(0xffffffff),
                  playedColor: Color(0xff2197f5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
