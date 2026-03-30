// RQ-NFR-001 / RQ-OBJ-009 / D-08 / D-27
// Declarative navigation graph for the application.
// All routes reference AppRoutes constants -- no inline path strings.
// Model: Claude Opus 4.6

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/home/home_screen.dart';
import '../../presentation/item_form/item_form_screen.dart';
import 'app_routes.dart';

/// Application router singleton.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    // itemCreate MUST precede itemEdit to prevent 'new' being captured as :id.
    GoRoute(
      path: AppRoutes.itemCreate,
      name: 'itemCreate',
      builder: (BuildContext context, GoRouterState state) =>
          const ItemFormScreen(),
    ),
    GoRoute(
      path: AppRoutes.itemEdit,
      name: 'itemEdit',
      builder: (BuildContext context, GoRouterState state) {
        final itemId = state.pathParameters['id']!;
        return ItemFormScreen(itemId: itemId);
      },
    ),
  ],
);
