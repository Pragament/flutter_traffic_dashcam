import 'package:car_dashcam/Model/extracted_text_model.dart';
import 'package:car_dashcam/provider/extractedtext_provider.dart';
import 'package:car_dashcam/provider/video_provider.dart';
import 'package:car_dashcam/screens/videoplayer/videoscreenplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart'; 
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hive/hive.dart';

class RecordinglistScreen extends ConsumerStatefulWidget {
  const RecordinglistScreen({super.key});

  @override
  _RecordinglistScreenState createState() => _RecordinglistScreenState();
}

class _RecordinglistScreenState extends ConsumerState<RecordinglistScreen> {
  bool isFavSelected = false;
  bool isTextExtracting = false;

  @override
  Widget build(BuildContext context) {
    final videoList = ref.watch(videoListProvider);
    final favVideolist = ref.watch(favoriteVideoListProvider);


    final filteredVideoList = isFavSelected ? favVideolist : videoList;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isFavSelected ? 'Favorite Recordings' : 'Recording List',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  isFavSelected = !isFavSelected;
                });
              },
              icon: Icon(Icons.star,
                  color: isFavSelected ? Colors.yellow : Colors.white),
            ),
          ),
        ],
      ),
      body: filteredVideoList.isEmpty
          ? Center(
              child: Text(isFavSelected
                  ? 'No favorite recordings available'
                  : 'No recordings available'),
            )
          : ListView.builder(
              itemCount: filteredVideoList.length,
              itemBuilder: (BuildContext context, index) {
                final video = filteredVideoList[index];

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VideoPlayerScreen(filePath: video.filePath),
                        ),
                      );
                    },
                    onLongPress: () {
                      _showShareSaveDialog(context, video.filePath,ref);
                    },
                    child: FutureBuilder<String?>(
                      future: generateThumbnail(video.filePath),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return _buildVideoTile(snapshot.data!, video);
                          } else {
                            return _buildErrorThumbnail(video);
                          }
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 220.0,
                            width: double.infinity,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return _buildErrorThumbnail(video);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showShareSaveDialog(BuildContext context, String videoPath, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.of(context).pop();
                  _shareVideo(videoPath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: const Text('Save to Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _saveVideoToGallery(videoPath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: isTextExtracting
                    ? LinearProgressIndicator(
                     value: 0.7, // Example progress value (70%)
                     valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Progress bar color
                     backgroundColor: Colors.grey[300],  // Background color of the bar
                    )
                    : Text("Extract Text"),
                onTap: () {
                   setState(() {
                   isTextExtracting = true;
                 });
                _videoTextGenerator(videoPath);

                  
                },
              ),
              ListTile(
                leading: const Icon(Icons.read_more),
                title: const Text('Show-Extract Text'),
                onTap: () {

                  _showExtractedDialog(context,videoPath ,ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  void _showExtractedDialog(BuildContext context , String videoPath ,WidgetRef ref)
  {
    final extractedTextList = ref.watch(ExtractedTextListProvider);
    ExtractedTextModel extractedText;
     bool videoExist = false;
    for(int i=0;i<extractedTextList.length;i++)
      {
        if(extractedTextList[i].videoPath == videoPath)
          {
            extractedText =extractedTextList[i];
       final textList= extractedText.text;//seprating the text and time stamp
        ListView.builder(
      itemCount: extractedTextList.length,
      itemBuilder: (BuildContext context, index) {

        final text = textList[index];
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child:
              GestureDetector(
                child: Row(
                  children: [
                    Text(text[index]!),
                    Spacer(),
                    Text("$index")
                  ],
                ) ,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideoPlayerScreen(filePath: videoPath),
                    ),
                  );
                },

              ),

        );
      }
    );
          }
        else
          {
            print("video not found");
          }
      }//for loop end

  }
//extarcting text from image
  Future<String> extractTextFromImage(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedTextResult =
        await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    return recognizedTextResult.text;
  }

  //this funtion extract and analyse the text from video
  Future<void> _videoTextGenerator(String videoPath) async {
   List< Map<int,String>> extractedTexts = [];
    try {
      final videoDuration = await _getVideoDuration(videoPath);
      //extracting each frame at every 1 second
      for (int i = 0; i < videoDuration.inSeconds; i++) {
        final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: videoPath,
          imageFormat: ImageFormat.PNG,
          maxHeight: 220,
          quality: 75,
          timeMs: i * 100,
        );
        if (thumbnailPath != null) {
          String text = await extractTextFromImage(thumbnailPath);
          print(text);
          //save the
          extractedTexts.add({i:text});
          await File(thumbnailPath).delete();
        }
      }
      print(extractedTexts);
      //create ExtractedText Model Object
  final result = ExtractedTextModel(videoPath: videoPath, text: extractedTexts);
      //extract searchable keyword here
      setState(() {
        isTextExtracting = false;
      });
      ref.read(ExtractedTextListProvider.notifier).addText(result, context);
    } catch (e) {
      print('Error in generating text  for $videoPath: $e');

    }
  }
//saving to hive
 

  void _shareVideo(String videoPath) {
    final XFile videoFile = XFile(videoPath);
    Share.shareXFiles([videoFile], text: 'Check out this video');
  }

  void _saveVideoToGallery(String videoPath) async {
    bool? result = await GallerySaver.saveVideo(videoPath);
    if (result != null && result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video saved to gallery!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save video to gallery')),
      );
    }
  }

  Future<String?> generateThumbnail(String videoPath) async {
    try {
      final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.PNG,
        maxHeight: 220,
        quality: 75,
      );
      return thumbnailPath;
    } catch (e) {
      print('Error generating thumbnail for $videoPath: $e');
      return null;
    }
  }

  Future<Duration> _getVideoDuration(String videoPath) async {
    final VideoPlayerController controller =
        VideoPlayerController.file(File(videoPath));
    await controller.initialize();
    final duration = controller.value.duration;
    controller.dispose();
    return duration;
  }

  Widget _buildVideoTile(String thumbnailPath, video) {
    return Container(
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
          SizedBox(
            height: 220.0,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.file(
                File(thumbnailPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_outline_sharp,
                color: Colors.blue, size: 48.0),
            onPressed: () {
              // Handled by GestureDetector's onTap
            },
          ),
          Positioned(
            bottom: 8.0,
            left: 8.0,
            child: FutureBuilder<Duration>(
              future: _getVideoDuration(video.filePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error',
                      style: TextStyle(color: Colors.red));
                } else if (snapshot.hasData) {
                  final duration = snapshot.data!;
                  return Text(
                    _formatDuration(duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return const Text('Duration not available',
                      style: TextStyle(color: Colors.white));
                }
              },
            ),
          ),
          Positioned(
            bottom: 8.0,
            right: 8.0,
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
    );
  }

  Widget _buildErrorThumbnail(video) {
    return Container(
      height: 220.0,
      width: double.infinity,
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
            child: ColoredBox(color: Colors.grey),
          ),
          const Icon(Icons.error, color: Colors.red, size: 48.0),
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
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
