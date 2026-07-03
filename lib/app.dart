import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/sign_in_screen.dart';
import 'features/home/home_screen.dart';
import 'features/tasks/providers/task_providers.dart';

/// Brand blue, matched to the clock face's night-quadrant color, used as the
/// seed for a bright, rounded, kid-friendly Material 3 theme.
const _seedColor = Color(0xFF2C4BA0);

class K24PlannerApp extends StatelessWidget {
  const K24PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: _seedColor);
    return MaterialApp(
      title: 'K24 Planner',
      // Always the bright theme, regardless of system dark mode: the app is
      // modeled after a colorful physical wall clock, not a dark-mode-aware
      // productivity tool.
      themeMode: ThemeMode.light,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.all(10),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w800),
          titleMedium: TextStyle(fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(fontSize: 17),
        ),
      ),
      home: const _AuthGate(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
  }
}

/// Shows [HomeScreen] once signed in to Google, [SignInScreen] otherwise.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return switch (authState) {
      AsyncData(:final value) =>
        value != null ? const HomeScreen() : const SignInScreen(),
      AsyncError(:final error) => Scaffold(
        body: Center(child: Text('Sign-in error: $error')),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}
