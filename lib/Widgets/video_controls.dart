import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoControls extends ConsumerWidget {
  const VideoControls({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ResolutionPreset resolutionPreset = ResolutionPreset.medium;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Clip Length',
                      labelStyle: TextStyle(fontSize: 15.0,fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0,),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Clip Count Limit',
                      labelStyle: TextStyle(fontSize: 15.0,fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0,),
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: 'Video Quality',
                      border: OutlineInputBorder(),
                    ),
                    value: resolutionPreset,
                    items: ResolutionPreset.values.map((preset) {
                      return DropdownMenuItem(
                        value: preset,
                        child: Text(preset.name,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.normal),),
                      );
                    }).toList(), onChanged: (ResolutionPreset? value) {},

                  ),

                )
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
            ],
          ),
        )
      ],
    );
  }
}
