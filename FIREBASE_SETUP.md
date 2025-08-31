
# Firebase setup — quick guide

1. Go to https://console.firebase.google.com/ and create a new project (My Modus).
2. Add Android app: provide package name (e.g. com.modus.fashion). Download `google-services.json`.
3. Add iOS app: provide bundle id, download `GoogleService-Info.plist`.
4. Place `google-services.json` into `frontend/android/app/` and `GoogleService-Info.plist` into `frontend/ios/Runner/`.
5. Add Firebase SDKs:
   - Add `firebase_core` and `firebase_messaging` to `pubspec.yaml` (see frontend/PUBSPEC_ADDITIONS.md).
6. Android: update `android/build.gradle` and `android/app/build.gradle` according to Firebase docs (add google-services plugin).
7. iOS: add Firebase initialization in `AppDelegate` if needed and ensure CocoaPods are installed.
8. In Firebase Console → Cloud Messaging → generate server key (for legacy) or setup Service Account for HTTP v1 API.
9. Store server key as environment variable `FCM_SERVER_KEY` for backend, and `JWT_SECRET` for auth.
10. Test by running app and using the backend endpoint `/api/push/send` (see backend handler example).
