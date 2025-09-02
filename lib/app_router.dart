import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reto_matematico/features/home/presentation/home_screen.dart';
import 'package:reto_matematico/features/game/presentation/game_screen.dart';
import 'package:reto_matematico/features/practice/presentation/practice_screen.dart';
import 'package:reto_matematico/features/store/presentation/store_screen.dart';
import 'package:reto_matematico/features/settings/presentation/settings_screen.dart';
import 'package:reto_matematico/features/stats/presentation/stats_screen.dart';
import 'package:reto_matematico/features/daily_challenge/presentation/daily_challenge_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/game/:mode',
        pageBuilder: (context, state) {
          final mode = state.pathParameters['mode']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: GameScreen(mode: mode),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/practice/:mode',
        pageBuilder: (context, state) {
          final mode = state.pathParameters['mode']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: PracticeScreen(mode: mode),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/store',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StoreScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/stats',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StatsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/daily-challenge',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DailyChallengeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
        ),
      ),
    ],
  );
});
