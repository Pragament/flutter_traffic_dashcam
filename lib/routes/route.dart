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
            final filePath = state.pathParameters['filePath']!;
            return VideoPlayerScreen(filePath: filePath);
          },
        ),
      ],
    ),
  ],
);
