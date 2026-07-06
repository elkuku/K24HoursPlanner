import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../tasks/providers/task_providers.dart';
import 'providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final account = ref.watch(authStateProvider).value;
    final appTitle = ref.watch(appTitleProvider).value ?? kDefaultAppTitle;
    final localeOverride = ref.watch(localeProvider).value;
    final effectiveLocale = localeOverride ?? Localizations.localeOf(context);
    final currentLanguage = kSupportedLocaleOptions.firstWhere(
      (option) => option.$1.languageCode == effectiveLocale.languageCode,
      orElse: () => kSupportedLocaleOptions.first,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
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
            title: Text(l10n.appTitleSettingLabel),
            subtitle: Text(appTitle),
            onTap: () => _editAppTitle(context, ref, appTitle),
          ),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(l10n.languageSettingLabel),
            subtitle: Text(currentLanguage.$2),
            onTap: () => _chooseLanguage(context, ref, currentLanguage.$1),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: Text(l10n.signOut),
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
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.appTitleSettingLabel),
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
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (newTitle != null) {
      await ref.read(appTitleProvider.notifier).setTitle(newTitle);
    }
  }

  Future<void> _chooseLanguage(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDialog<Locale>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseLanguage),
        content: RadioGroup<Locale>(
          groupValue: currentLocale,
          onChanged: (value) => Navigator.of(context).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (locale, name) in kSupportedLocaleOptions)
                RadioListTile<Locale>(value: locale, title: Text(name)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    if (selected != null) {
      await ref.read(localeProvider.notifier).setLocale(selected);
    }
  }
}
