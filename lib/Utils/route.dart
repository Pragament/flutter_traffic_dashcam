import 'package:car_dashcam/screens/recording_list_screen.dart';
import 'package:car_dashcam/screens/recording_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter approuter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return RecordingScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'recordings',
          builder: (BuildContext context, GoRouterState state) {
            return RecordingsListScreen();
          },
        ),
      ],
    ),
  ],
);
