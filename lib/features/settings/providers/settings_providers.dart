import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kDefaultAppTitle = '🕐 K24 Planner';

const _appTitleKey = 'app_title';

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
