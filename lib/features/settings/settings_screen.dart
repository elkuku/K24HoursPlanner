import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tasks/providers/task_providers.dart';
import 'providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(authStateProvider).value;
    final appTitle = ref.watch(appTitleProvider).value ?? kDefaultAppTitle;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (account != null)
            ListTile(
              leading: const Icon(Icons.account_circle_rounded),
              title: Text(account.displayName ?? account.email),
              subtitle: Text(account.email),
            ),
          ListTile(
            leading: const Icon(Icons.title_rounded),
            title: const Text('App title'),
            subtitle: Text(appTitle),
            onTap: () => _editAppTitle(context, ref, appTitle),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign out'),
            onTap: () {
              ref.read(googleAuthServiceProvider).signOut();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _editAppTitle(
    BuildContext context,
    WidgetRef ref,
    String currentTitle,
  ) async {
    final controller = TextEditingController(text: currentTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(hintText: kDefaultAppTitle),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newTitle != null) {
      await ref.read(appTitleProvider.notifier).setTitle(newTitle);
    }
  }
}
