import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kDefaultAppTitle = '🕐 K24 Planner';

const _appTitleKey = 'app_title';
const _localeKey = 'locale';

/// The supported UI languages, in the order offered in the settings screen.
/// Names are each language's own endonym, so they aren't translated.
const List<(Locale locale, String nativeName)> kSupportedLocaleOptions = [
  (Locale('en'), 'English'),
  (Locale('de'), 'Deutsch'),
  (Locale('es'), 'Español'),
];

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

/// The app bar title, persisted across launches. Defaults to
/// [kDefaultAppTitle] until the user overrides it from the settings screen.
class AppTitleNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return prefs.getString(_appTitleKey) ?? kDefaultAppTitle;
  }

  Future<void> setTitle(String title) async {
    final trimmed = title.trim();
    final value = trimmed.isEmpty ? kDefaultAppTitle : trimmed;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_appTitleKey, value);
    state = AsyncData(value);
  }
}

final appTitleProvider = AsyncNotifierProvider<AppTitleNotifier, String>(
  AppTitleNotifier.new,
);

/// The user's chosen UI language, persisted across launches. `null` means
/// "follow the system locale" — [K24PlannerApp] passes it straight to
/// `MaterialApp.locale`, which falls back to its own resolution logic against
/// `AppLocalizations.supportedLocales` when null.
class LocaleNotifier extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final code = prefs.getString(_localeKey);
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
    state = AsyncData(locale);
  }
}

final localeProvider = AsyncNotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
