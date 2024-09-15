import 'package:car_dashcam/enum/enum.dart';
import 'package:car_dashcam/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'Adapter/duration_adapter.dart';
import 'Model/video_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(VideoModelAdapter());
  Hive.registerAdapter(DurationAdapter()); // Ensure this line is included
  await Hive.openBox<VideoModel>('videos');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Dash Cam App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
