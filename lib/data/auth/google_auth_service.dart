import 'package:google_sign_in/google_sign_in.dart';

import 'google_client_config.dart';

/// OAuth scope requested for reading the user's calendar events. Least
/// privilege for the current read-only UI (see "Read-only UI" in
/// CLAUDE.md) — `CalendarService.createTask`/`updateTask`/`deleteTask` are
/// dormant and would need `calendar.events` (read/write) instead of this if
/// an add/edit UI is ever reintroduced.
const String calendarEventsReadonlyScope =
    'https://www.googleapis.com/auth/calendar.events.readonly';

/// Thin wrapper around `GoogleSignIn.instance` (v7's Credential
/// Manager-based API). [initialize] must complete before any other method is
/// called.
class GoogleAuthService {
  final GoogleSignIn _signIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _signIn.initialize(serverClientId: googleServerClientId);
    _initialized = true;
  }

  /// Sign-in/sign-out events as a plain `GoogleSignInAccount?` stream (null
  /// on sign-out).
  Stream<GoogleSignInAccount?> get accountEvents =>
      _signIn.authenticationEvents.map(
        (event) => switch (event) {
          GoogleSignInAuthenticationEventSignIn(:final user) => user,
          GoogleSignInAuthenticationEventSignOut() => null,
        },
      );

  /// Restores a previous sign-in with minimal/no UI, or returns null if
  /// there isn't one.
  Future<GoogleSignInAccount?> attemptLightweightSignIn() async {
    final future = _signIn.attemptLightweightAuthentication();
    if (future == null) return null;
    return future;
  }

  /// Starts an interactive sign-in flow.
  Future<GoogleSignInAccount> signIn() {
    return _signIn.authenticate(scopeHint: const [calendarEventsReadonlyScope]);
  }

  Future<void> signOut() => _signIn.signOut();
}
