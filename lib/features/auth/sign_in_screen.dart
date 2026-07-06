import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../tasks/providers/task_providers.dart';

/// Shown when there's no signed-in Google account. K24 Planner reads and
/// writes tasks as events on the user's Google Calendar, so sign-in is
/// required before anything else can be shown.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _signingIn = false;

  Future<void> _signIn() async {
    setState(() => _signingIn = true);
    try {
      await ref.read(googleAuthServiceProvider).signIn();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.signInFailed('$e'))));
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: colorScheme.primaryContainer,
                child: const Text('🕐', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.signInSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _signingIn ? null : _signIn,
                icon: _signingIn
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(l10n.signInButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
