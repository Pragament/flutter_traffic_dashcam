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
        GoRoute(
          path: 'video_player',
          builder: (BuildContext context, GoRouterState state) {
            final filePath = state.uri.queryParameters['filePath']!;
            // Parse timestamp safely
            final int? durationInSeconds =
                int.tryParse(state.uri.queryParameters['timestamp'] ?? '0');
            final videoTimestamp = Duration(seconds: durationInSeconds ?? 0);

            return VideoPlayerScreen(
              filePath: filePath,
              videoTimestamp: videoTimestamp,
            );
          },
        ),
        GoRoute(
          path: 'extracted_text/:videoPath',
          builder: (BuildContext context, GoRouterState state) {
            final videoPath =
                Uri.decodeComponent(state.pathParameters['videoPath']!);
            return ExtractedTextScreen(videoPath: videoPath);
          },
        ),
      ],
    ),
  ],
);
