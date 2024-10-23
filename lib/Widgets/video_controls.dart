import 'package:camera/camera.dart';
import 'package:car_dashcam/provider/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VideoControls extends ConsumerStatefulWidget {
  final Function( bool isFav) onSettingsChanged;

  const VideoControls({super.key, required this.onSettingsChanged});

  @override
  _VideoControlsState createState() => _VideoControlsState();
}

class _VideoControlsState extends ConsumerState<VideoControls> {


  bool isFav = false;



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    context.go('/rec_list');
                  },
                  child: Container(
                      height: 50.0,
                      width: 150.0,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15.0)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Recordings",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Icon(
                            Icons.list,
                            color: Colors.white,
                            size: 30.0,
                          )
                        ],
                      )),
                ),
                InkWell(//favorite button
                  onTap: () {
                    setState(() {
                      isFav = !isFav;
                      _updateSettings();
                    });
                  },
                  child: Container(
                      height: 50.0,
                      width: 150.0,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Favourite",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Icon(
                            Icons.star,
                            color: ref.read(settingsProvider).isFavorite ? Colors.yellow : Colors.white,
                            size: 30.0,
                          )
                        ],
                      )),
                ),
                InkWell(//setting gear button for setting page
                  onTap: () {
                    context.go('/settings');
                  },
                  child: Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15.0)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 5.0,
                          ),
                          Icon(
                            Icons.settings,
                            color:Colors.white,
                            size: 30.0,
                          )
                        ],
                      )
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void _updateSettings() {
    widget.onSettingsChanged(isFav);
  }
}
