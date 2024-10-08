import 'package:car_dashcam/screens/extractedtextscreen.dart';
import 'package:car_dashcam/screens/recordinglist_screen.dart';
import 'package:car_dashcam/screens/videoplayer/videoscreenplayer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'rec_list',
          builder: (BuildContext context, GoRouterState state) {
            return const RecordinglistScreen();
          },
        ),
        // GoRoute(
        //   path: 'video_player',
        //   builder: (BuildContext context, GoRouterState state) {
        //     final filePath = state.pathParameters['filePath']!;
        //     final int? durationInSeconds = state.pathParameters['timestamp'] != null
        //         ? int.tryParse(state.pathParameters['timestamp']!)
        //         : 0;//assign null when no value is provided
        //
        //     // If duration is provided, use it; otherwise, use the default value
        //     return VideoPlayerScreen(
        //       filePath: filePath,
        //       videoTimestamp : durationInSeconds != null
        //           ? Duration(seconds: durationInSeconds)
        //           : Duration(seconds: 0), // The screen will handle the default duration if null
        //     );
        //   },
        // ),
        GoRoute(
          path: 'video_player',
          builder: (BuildContext context, GoRouterState state) {
            final filePath = state.pathParameters['filePath']!;
            return VideoPlayerScreen(filePath: filePath);
          },
        ),

        // GoRoute(
        //   path: 'extracted_text',
        //   builder: (BuildContext context, GoRouterState state) {
        //     final videoPath = state.pathParameters['videoPath']!;
        //     return ExtractedTextScreen(videoPath: videoPath);
        //   },
        // ),
      ],
    ),
  ],
);
