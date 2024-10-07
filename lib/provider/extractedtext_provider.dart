import 'package:car_dashcam/Model/extracted_text_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../Model/video_model.dart';
import '../hive/hive_boxes.dart';

// Video list provider
final ExtractedTextListProvider = StateNotifierProvider<ExtractedTextNotifier, List<ExtractedTextModel>>(
      (ref) =>ExtractedTextNotifier(),
);
//video notifier(listen for the change )
class ExtractedTextNotifier extends StateNotifier<List<ExtractedTextModel>> {
  ExtractedTextNotifier() : super([]) {
    loadExtractedText();//initializing the text
  }


  Future<void> loadExtractedText() async {
    try {
      var box = HiveBoxes.getExtractedTextBox();
      final texts = box.values.toList();
      state = texts.cast<ExtractedTextModel>(); // Cast to the correct type
      print('Extracted Text loaded: ${state.length}');
    } catch (e, stackTrace) {
      print('Error loading Texts: $e');
      print('Stack trace: $stackTrace');
    }
  }


  void addText(ExtractedTextModel text , BuildContext context) async {
    try {

      var box = HiveBoxes.getExtractedTextBox();
      await box.put(text.videoPath,text); // Use put to replace the video and text.videoPath as key
      state = [...state, text]; // Replace the state with the new list
      print('Current box values: ${box.values.toList()}');
      print('Video Text added/updated successfully. ${text.videoPath}');

    } catch (e) {
      print('Error adding/updating video tetxt: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add/update video: $e')),
      );
    }
  }
}







