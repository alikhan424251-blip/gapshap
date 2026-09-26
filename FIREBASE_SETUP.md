# GapShap Firebase Setup — 2026-09-26

## Firebase Project (created 2026-09-26)
- **Project name:** GapShap
- **Project ID:** `gapshap-bfdf9`
- **Console:** https://console.firebase.google.com/project/gapshap-bfdf9/overview
- **Google account used:** alikhan424251@gmail.com (signed in via Secure Vault; 2FA approved on user's Vivo Y17s)
- **Analytics:** skipped
- **Gemini in Firebase:** left enabled (default)

## Enabled services
- ✅ **Authentication → Phone provider:** enabled ("Success: Phone enabled")
- ✅ **Firestore Database:** created in test mode, location **asia-south1 (Mumbai)**

## NOT set up
- ❌ **Cloud Storage:** requires Blaze billing plan (card needed). User has no card (2026-09-26), so Storage skipped for now. Text chat works without it; media sharing needs Blaze later.

## Flutter app scaffold
- Code at `~/workspace/gapshap-app/` (pubspec, main.dart, services, screens, README)
- `lib/firebase_options.dart` still has PLACEHOLDER values — needs `flutterfire configure` with project ID `gapshap-bfdf9` once Firebase CLI is available.
