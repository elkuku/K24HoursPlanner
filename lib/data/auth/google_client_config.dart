/// The Google Cloud "Web application" OAuth client ID (looks like
/// `xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com`).
///
/// `google_sign_in`'s Android implementation uses Android's Credential
/// Manager, which requires this even for a purely Android app — it's used as
/// the token audience, alongside a separate "Android" OAuth client
/// (identified by package name + signing SHA-1) that isn't referenced from
/// code at all. Both clients must live in the same Google Cloud project,
/// with the Calendar API enabled and this app's account added as an OAuth
/// consent screen test user. See CLAUDE.md's "Google Cloud setup" section
/// for the full one-time checklist.
const String googleServerClientId =
    '779732109026-ceoj7ccq2ftn55ib4vnc9n5g24l9beo8.apps.googleusercontent.com';
