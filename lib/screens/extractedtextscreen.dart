import 'dart:io';

import 'package:car_dashcam/Model/extracted_text_model.dart';
import 'package:car_dashcam/provider/extractedtext_provider.dart';
import 'package:car_dashcam/routes/route.dart';
import 'package:car_dashcam/screens/videoplayer/videoscreenplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ExtractedTextScreen extends ConsumerStatefulWidget {
  final String videoPath;

  ExtractedTextScreen({super.key, required this.videoPath});

  @override
  _ExtractedTextScreenState createState() => _ExtractedTextScreenState();
}

class _ExtractedTextScreenState extends ConsumerState<ExtractedTextScreen> {
  late TextEditingController _searchController;
  int totalFrame = 0;
  int currentFrameNo = 1;
  bool isTextExtracting = false;
  List<Map<int, String>> extractedTexts = [];
  List<Map<int, String>> _filteredTextList = [];
  //extarcting text from image
  Future<String> extractTextFromImage(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedTextResult =
        await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    return recognizedTextResult.text;
  }

  //check it exist or not in hive
  Future<bool> isVideoPathExist(String videoPath, WidgetRef ref) async {
    final extractedTextList = ref.watch(ExtractedTextListProvider);
    for (int i = 0; i < extractedTextList.length; i++) {
      if (extractedTextList[i].videoPath == videoPath) {
        List<Map<int, String>> textList = extractedTextList[i].text;
        for (int j = 0; j < textList.length; j++) {
          print("isvideoPathexist function ");
          await Future.delayed(
              Duration(milliseconds: 500)); // Adjust delay here
          setState(() {
            extractedTexts.add(textList[j]);
            currentFrameNo = j + 1;
          });
        }
        //when all text extracted
        setState(() {
          isTextExtracting = false;
        });
        return true;
      }
    }
    return false;
  }

  //this funtion extract and analyse the text from video
  Future<void> _videoTextGenerator(String videoPath, WidgetRef ref) async {
    final videoDuration = await _getVideoDuration(videoPath);
    setState(() {
      isTextExtracting = true;
      totalFrame = videoDuration.inSeconds;
      currentFrameNo = 0;
    });
    //check videoPath exist in hive or not
    if (await isVideoPathExist(videoPath, ref)) return;
//else
    try {
      //extracting each frame at every 1 second
      for (int i = 0; i < videoDuration.inSeconds; i++) {
        final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: videoPath,
          imageFormat: ImageFormat.PNG,
          maxHeight: 220,
          quality: 75,
          timeMs: i * 1000,
        );
        if (thumbnailPath != null) {
          String text = await extractTextFromImage(thumbnailPath);
          print(text);
          print("OCR Running");
          //save the
          if (text.isNotEmpty) {
            setState(() {
              extractedTexts.add({i: text});
            });
          }
          setState(() {
            currentFrameNo = i + 1;
          });
          File(thumbnailPath).delete();
        }
      }
      //create ExtractedText Model Object
      ExtractedTextModel result =
          ExtractedTextModel(videoPath: videoPath, text: extractedTexts);
      ref.read(ExtractedTextListProvider.notifier).addText(result, context);
    } catch (e) {
      print('Error in generating text  for $videoPath: $e');
    } finally {
      setState(() {
        isTextExtracting = false;
      });
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

  @override
  void initState() {
    super.initState();
    _videoTextGenerator(widget.videoPath, ref);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter the text list based on search query
  void _filterTextList(List<Map<int, String>> textList, String query) {
    setState(() {
      _filteredTextList = textList
          .where((entry) =>
              entry.values.first.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ExtractedText Screen",
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: isTextExtracting
                  ? Text("$currentFrameNo/$totalFrame")
                  : Text("")),
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: isTextExtracting ? CircularProgressIndicator() : Text("")),
        ],
      ),
      body: extractedTexts.isEmpty
          ? Center(
              child: Text("No Text Found"),
            )
          : Column(
              children: [
                // Search bar for filtering text
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _filterTextList(extractedTexts, value);
                    },
                    decoration: InputDecoration(
                      labelText: "Search extracted text",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: extractedTexts.isEmpty
                      ? Center(child: Text("No Text Found"))
                      : ListView.builder(
                          itemCount: _filteredTextList.isNotEmpty
                              ? _filteredTextList.length
                              : extractedTexts.length,
                          itemBuilder: (BuildContext context, int index) {
                            final textEntry = _filteredTextList.isNotEmpty
                                ? _filteredTextList[index]
                                : extractedTexts[index];
                            String textWritten = textEntry.values.first;
                            int timeInt = textEntry.keys.first;
                            Duration timeStamp = Duration(seconds: timeInt);

                            return InkWell(
                              onTap: () {
                                context.go(
                                  '/video_player?filePath=${Uri.encodeComponent(widget.videoPath)}&timestamp=${timeStamp.inSeconds}',
                                );
                              },
                              child: Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          textWritten,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        timeStamp
                                            .toString(), // Display timestamp
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
