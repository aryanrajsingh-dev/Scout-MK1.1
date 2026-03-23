import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:websocket_app/features/websocket/presentation/screens/compute_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
          ComputeScreen(),
    ),
  ],
);
