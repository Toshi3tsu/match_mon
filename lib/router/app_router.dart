import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/matches_screen.dart';
import '../screens/production_screen.dart';
import '../screens/production_result_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/player_character_screen.dart';
import '../screens/dungeon_exploration_screen.dart';
import '../screens/match_session_screen.dart';
import '../screens/consultation_office_screen.dart';
import '../screens/expedition_result_screen.dart';
import '../models/collaboration.dart';
import '../widgets/bottom_navigation.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Scaffold(
        body: const HomeScreen(),
        bottomNavigationBar: BottomNavigation(currentPath: '/'),
      ),
    ),
    GoRoute(
      path: '/discover',
      builder: (context, state) => Scaffold(
        body: const DiscoverScreen(),
        bottomNavigationBar: BottomNavigation(currentPath: '/discover'),
      ),
    ),
    GoRoute(
      path: '/collaborations',
      builder: (context, state) => Scaffold(
        body: const MatchesScreen(),
        bottomNavigationBar: BottomNavigation(currentPath: '/collaborations'),
      ),
    ),
    GoRoute(
      path: '/production',
      builder: (context, state) => Scaffold(
        body: const ProductionScreen(),
        bottomNavigationBar: BottomNavigation(currentPath: '/production'),
      ),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) {
            final resultId = state.uri.queryParameters['id'];
            return Scaffold(
              body: ProductionResultScreen(resultId: resultId),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/player-character',
      builder: (context, state) => const PlayerCharacterScreen(),
    ),
    GoRoute(
      path: '/dungeon',
      builder: (context, state) => Scaffold(
        body: const DungeonExplorationScreen(),
        bottomNavigationBar: BottomNavigation(currentPath: '/dungeon'),
      ),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) {
            final resultId = state.uri.queryParameters['id'];
            return Scaffold(
              body: ExpeditionResultScreen(resultId: resultId),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/match-session',
      builder: (context, state) {
        final collaboration = state.extra as Collaboration;
        return Scaffold(
          body: MatchSessionScreen(collaboration: collaboration),
        );
      },
    ),
    GoRoute(
      path: '/consultation-office',
      builder: (context, state) => Scaffold(
        body: const ConsultationOfficeScreen(),
        bottomNavigationBar: BottomNavigation(currentPath: '/consultation-office'),
      ),
    ),
  ],
);

