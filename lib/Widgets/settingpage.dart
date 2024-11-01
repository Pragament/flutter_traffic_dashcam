import 'package:camera/camera.dart';
import 'package:car_dashcam/provider/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VideoSettingsPage extends ConsumerStatefulWidget {
  const VideoSettingsPage({Key? key}) : super(key: key);

  @override
  _VideoSettingsPageState createState() => _VideoSettingsPageState();
}

class _VideoSettingsPageState extends ConsumerState<VideoSettingsPage> {
  ResolutionPreset resolutionPreset = ResolutionPreset.medium;
  final TextEditingController _clipLengthController = TextEditingController();
  final TextEditingController _clipCountController = TextEditingController();

  @override
  void dispose() {
    _clipLengthController.dispose();
    _clipCountController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    // Set dummy data for the text fields
    _clipLengthController.text = ref.read(settingsProvider).clipLength.toString() ; // previous clip length value
    _clipCountController.text = ref.read(settingsProvider).clipCountLimit.toString(); // previous clip count limit value
    resolutionPreset= ref.read(settingsProvider).videoQuality;
  }

  @override
  Widget build(BuildContext context) {
    // Check the current orientation
    var isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLandscape ? _buildLandscapeLayout(context) : _buildPortraitLayout(context),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _clipLengthController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Clip Length (minutes)',
            labelStyle: TextStyle(fontSize: 14.0),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            //_updateSettings();
          },
        ),
        const SizedBox(height: 20.0),
        TextField(
          controller: _clipCountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Clip Count Limit',
            labelStyle: TextStyle(fontSize: 14.0),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            //_updateSettings();
          },
        ),
        const SizedBox(height: 20.0),
        DropdownButtonFormField<ResolutionPreset>(
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
                style: const TextStyle(fontSize: 15.0),
              ),
            );
          }).toList(),
          onChanged: (ResolutionPreset? value) {
            if (value != null) {
              setState(() {
                resolutionPreset = value;
              });
              //_updateSettings();
            }
          },
        ),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              _updateSettings();
              context.pop(); // Goes back to the previous route
            },
            child: Text("Save"),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _clipLengthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Clip Length (minutes)',
                  labelStyle: TextStyle(fontSize: 14.0),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  //_updateSettings();
                },
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _clipCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Clip Count Limit',
                  labelStyle: TextStyle(fontSize: 14.0),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  //_updateSettings();
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              DropdownButtonFormField<ResolutionPreset>(
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
                      style: const TextStyle(fontSize: 15.0),
                    ),
                  );
                }).toList(),
                onChanged: (ResolutionPreset? value) {
                  if (value != null) {
                    setState(() {
                      resolutionPreset = value;
                    });
                    //_updateSettings();
                  }
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _updateSettings();
                  context.pop(); // Goes back to the previous route
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateSettings() {
    final clipLength = int.tryParse(_clipLengthController.text) ?? 1;
    final clipCountLimit = int.tryParse(_clipCountController.text) ?? 10;
    // Update the global settingsProvider when settings are changed
    ref
        .read(settingsProvider.notifier)
        .updateSettings(clipLength, clipCountLimit, resolutionPreset);
    setState(() {
      // Update the UI
    });
  }
}
