import 'package:camera/camera.dart';
import 'package:car_dashcam/provider/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VideoControls extends ConsumerStatefulWidget {
  final Function(int clipLength, int clipCountLimit, ResolutionPreset videoQuality, bool isFav) onSettingsChanged;

  const VideoControls({super.key, required this.onSettingsChanged});

  @override
  _VideoControlsState createState() => _VideoControlsState();
}

class _VideoControlsState extends ConsumerState<VideoControls> {
  ResolutionPreset resolutionPreset = ResolutionPreset.medium;
  final TextEditingController _clipLengthController = TextEditingController();
  final TextEditingController _clipCountController = TextEditingController();

  bool isFav = false;


  @override
  void dispose() {
    _clipLengthController.dispose();
    _clipCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final makeFav = ref.watch(videoServiceProvider);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _clipLengthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Clip Length (minutes)',
                      labelStyle: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _updateSettings();
                    },
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    controller: _clipCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Clip Count Limit',
                      labelStyle: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _updateSettings();
                    },
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: DropdownButtonFormField<ResolutionPreset>(
                    decoration: const InputDecoration(
                      labelText: 'Video Quality',
                      border: OutlineInputBorder(),
                    ),
                    value: resolutionPreset,
                    items: ResolutionPreset.values.map((preset) {
                      return DropdownMenuItem(
                        value: preset,
                        child: Text(
                          preset.name,
                          style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal),
                        ),
                      );
                    }).toList(),
                    onChanged: (ResolutionPreset? value) {
                      if (value != null) {
                        setState(() {
                          resolutionPreset = value;
                        });
                        _updateSettings();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
                      width: 180.0,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15.0)
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Recordings",style: TextStyle(color: Colors.white, fontSize: 20.0),),
                          SizedBox(width: 5.0,),
                          Icon(Icons.list,color: Colors.white,size: 30.0,)],)
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isFav = !isFav;
                      _updateSettings();
                    });
                  },
                  child: Container(
                      height: 50.0,
                      width: 180.0,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15.0)
                      ),
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Favourite",style: TextStyle(color: Colors.white, fontSize: 20.0),),
                          const SizedBox(width: 5.0,),
                          Icon(Icons.star,color: isFav ? Colors.yellow : Colors.white,size: 30.0,)],)
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
    final clipLength = int.tryParse(_clipLengthController.text) ?? 1;
    final clipCountLimit = int.tryParse(_clipCountController.text) ?? 10;
    widget.onSettingsChanged(clipLength, clipCountLimit, resolutionPreset, isFav);
  }
}
