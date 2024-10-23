import 'package:car_dashcam/hive/hive_boxes.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../Model/video_model.dart';
import '../Widgets/video_controls.dart';
import '../provider/video_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool isFav=false;
  @override
  Widget build(BuildContext context) {
    final cameraControllerAsyncValue = ref.watch(cameraControllerProvider);
    Future<void> recButton(BuildContext context) async {
      final cameraController = ref.read(cameraControllerProvider).value;
      if (ref.read(settingsProvider).isFavorite) {
        var box = HiveBoxes.getFavVideosBox();
        box.clear();
      } else {
        var box = HiveBoxes.getVideosBox();
        box.clear();
      }
      if (cameraController != null && cameraController.value.isInitialized) {
        final isRecording =
            ref.read(recordingStateProvider); // Check recording state

        try {
          if (!isRecording) {
            // Start recording multiple clips
            ref.read(recordingStateProvider.notifier).state =
                true; // Update state to recording
            int clipcount = ref.read(settingsProvider).clipCountLimit;
            WakelockPlus.enable(); //wakeup screen while recording
            for (int i = 0; i < clipcount; i++) {
              try {
                VideoModel? recordedclip =
                    await ref.read(videoServiceProvider)?.recordClip(
                          clipLength: Duration(
                              minutes: ref.read(settingsProvider).clipLength),
                          quality: ref.read(settingsProvider).videoQuality,
                        );
                if (recordedclip == null)
                  continue;
                else if (ref
                    .read(settingsProvider)
                    .isFavorite) //if fav  button pressed
                {
                  ref
                      .read(favoriteVideoListProvider.notifier)
                      .addFavVideo(recordedclip, context);
                  ref
                      .read(settingsProvider.notifier)
                      .updateIsFavorite(false); //update the fav
                } else {
                  ref
                      .read(videoListProvider.notifier)
                      .addVideo(recordedclip, context);
                }
                if (i + 1 >= clipcount) {
                  print('Clip count limit reached. Stopping recording.');
                  break;
                }

                setState(() {
                });
              } catch (e) {
                print('Error while recoding clip ${i + 1}:$e');
                break;
              }
            }
          } //isRecording end;
          ref.read(recordingStateProvider.notifier).state =
              false; // Update state to not recording
          WakelockPlus.disable(); //stop wakeing-up
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
          ref.read(recordingStateProvider.notifier).state =
              false; // Reset recording state on error
        }
      } else {
        // Handle case when the camera is not initialized or is null
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera not initialized')),
        );
      }
    };
    DateTime currentTime = DateTime.now();
    // Format the time using intl
    String formattedTime = DateFormat('hh:mm:ss a').format(currentTime);

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return cameraControllerAsyncValue.when(
            data: (cameraController) {
              if (cameraController != null &&
                  cameraController.value.isInitialized) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    double cameraPreviewHeight =
                        orientation != Orientation.landscape
                            ? constraints.maxHeight * 0.9
                            : constraints.maxHeight * 0.97;
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
                              Positioned(
                                  left: 16.0,
                                  top: 20,
                                  child: Text(ref.read(recordingStateProvider.notifier).state?"Current Clip started at $formattedTime ":"",
                                  style: TextStyle(
                                    fontWeight:FontWeight.bold,
                                    fontSize:25,
                                    color: Colors.white,
                                  ),),
                              ),
                            if (orientation == Orientation.landscape)
                              Positioned(
                                  right: 16.0,
                                  child: Column(
                                    children: [
                                      //record/stop button
                                      FloatingActionButton(
                                        onPressed: () async {
                                          await recButton(context);
                                        },
                                        disabledElevation: 0.0,
                                        shape: const CircleBorder(),
                                        backgroundColor:
                                        ref.watch(recordingStateProvider)
                                            ? Colors.black
                                            : Colors.white,
                                        // Color based on recording state
                                        child: Icon(
                                          ref.watch(recordingStateProvider)
                                              ? Icons.stop
                                              : Icons.fiber_manual_record,
                                          // Icon based on recording state
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      //setting button(gear icon)
                                      FloatingActionButton(
                                          onPressed: () {
                                            context.go('/settings');
                                          },
                                          child: const Icon(Icons.settings)),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      //recording List icon
                                      FloatingActionButton(
                                        onPressed: () {
                                          context.go('/rec_list');
                                        },
                                        child: const Icon(Icons.list),
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      //favorite icon
                                      FloatingActionButton(
                                        onPressed: () {
                                          setState(() {
                                            isFav=!isFav;
                                          });
                                          print(isFav);
                                          ref
                                              .read(settingsProvider.notifier)
                                              .updateIsFavorite(isFav);



                                        },
                                        child:  Icon(
                                          Icons.star,
                                          color: ref.read(settingsProvider).isFavorite ? Colors.yellow : Colors.white,
                                          size: 30.0,
                                        ),
                                      )
                                    ],
                                  ))
                            else
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 20.0,
                                  bottom: 20.0,
                                  top: cameraPreviewHeight * 0.02,
                                ),
                                child: FloatingActionButton(
                                  onPressed: () async {
                                    await recButton(context);
                                  },
                                  disabledElevation: 0.0,
                                  shape: const CircleBorder(),
                                  backgroundColor:
                                      ref.watch(recordingStateProvider)
                                          ? Colors.black
                                          : Colors.white,
                                  // Color based on recording state
                                  child: Icon(
                                    ref.watch(recordingStateProvider)
                                        ? Icons.stop
                                        : Icons.fiber_manual_record,
                                    // Icon based on recording state
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        if (orientation != Orientation.landscape)
                          VideoControls(
                            onSettingsChanged: (

                                bool isFavVideo) {
                              // Update the global settingsProvider when settings are changed

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
          );
        },
      ),
    );
  }
}
