import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
              padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Clip Length',
                        labelStyle: TextStyle(fontSize: 12.0,fontWeight: FontWeight.normal),
                        border: OutlineInputBorder(
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0,),
                  const Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Clip Count Limit',
                        labelStyle: TextStyle(fontSize: 12.0,fontWeight: FontWeight.normal),
                        border: OutlineInputBorder(
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0,),
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
                    onTap: () {},
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
                            Text("Favourite",style: TextStyle(color: Colors.white, fontSize: 20.0),),
                            SizedBox(width: 5.0,),
                            Icon(Icons.star,color: Colors.white,size: 30.0,)],)
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
    );
  }
}
