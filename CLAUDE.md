# News Bucket: notes for Claude

Personal Android news aggregator in Flutter (Claude/Anthropic, AI, programming, security,
stocks & ETFs, crypto). Used by the owner and two friends; APKs are installed by hand from
GitHub Releases, no Play Store, no backend. Public repo: https://github.com/albertrzad18/news-bucket

The user writes in Polish (often with typos): reply in Polish. Code, comments, commits, README
and app UI are in English.

## Environment (Windows 11)

- Flutter stable 3.47.8 in `C:\dev\flutter`, installed from the official zip (not a git clone).
  In Git Bash prefix commands with `export PATH="/c/dev/flutter/bin:$PATH" &&`; in PowerShell
  with `$env:Path = "C:\dev\flutter\bin;$env:Path";`.
- Android SDK: `%LOCALAPPDATA%\Android\Sdk` (cmdline-tools, licenses accepted, NDK
  `28.2.13676358` installed manually). adb: `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`.
- Emulator: AVD `Medium_Phone_API_37.0` → `emulator-5554`. Start with
  `flutter emulators --launch Medium_Phone_API_37.0`. A black screen usually means the display
  is asleep: `adb shell input keyevent KEYCODE_WAKEUP`. The first opened article shows Chrome's
  first-run screen: tap "Use without an account".
- The network is slow (~130 KB/s at times). Run large downloads and first Gradle builds in the
  background and don't kill them for being slow. Gradle wrapper 9.8.2, JDK 21 locally (CI: 17).
- Only one Gradle build at a time: if the user pressed F5 in VS Code, don't start another build
  (they block each other's files). Check for running `java`/`gradle` processes first.
- VS Code: Flutter extension, `.vscode/launch.json` ("News Bucket (debug)"). The user runs the
  app with F5 and may need short step-by-step instructions.

## Commands

```sh
flutter pub get
dart format lib test tool          # CI fails on unformatted code
flutter analyze                    # must be 0 issues
flutter test
dart run tool/check_sources.dart   # fetch every source live, print item counts
dart run build_runner build        # after changing tables in lib/data/db
flutter build apk --debug --target-platform android-x64   # fastest build for the emulator
```

## Architecture

- `lib/core/` theme, go_router (`StatefulShellRoute`, tabs Feed / Saved / Settings), dio client,
  settings in shared_preferences, utils. `lib/data/` models, own RSS/Atom/RDF parser on `xml`,
  JSON parsers (HN Algolia, DEV), drift DB (`articles`, `source_state`; 30-day retention, saved
  kept forever), `news_repository.dart`. `lib/features/` feed, saved, settings, notifications.
- State: flutter_riverpod without codegen.
- Background notifications: workmanager (hourly, network required) + flutter_local_notifications,
  one summary notification, `notified` flag on articles. WorkManager jobs live in a JobScheduler
  namespace: `adb shell cmd jobscheduler run -f -n androidx.work.systemjobscheduler
  com.albertrzad.newsbucket <job id>` (id from `adb shell dumpsys jobscheduler | grep "JOB.*newsbucket"`).
  WorkManager skips a periodic run forced before its hour is up ("executed before schedule"), so
  to test right away switch notifications off and on in Settings: the re-registered task runs
  immediately in the background isolate. To get "new" articles, pull the DB with
  `adb exec-out run-as com.albertrzad.newsbucket cat app_flutter/news_bucket.sqlite`, delete a few
  rows of a bell source (no sqlite3 on the emulator, no Python on the host: use a throwaway Dart
  script with `package:sqlite3`) and push it back with `run-as ... sh -c 'cat /data/local/tmp/x >
  app_flutter/news_bucket.sqlite'` while the app is stopped. `am force-stop` cancels the job until
  the app starts again. In Git Bash set `MSYS_NO_PATHCONV=1` for adb commands with device paths.
  applicationId: `com.albertrzad.newsbucket`.
- Sources live in `assets/sources.json`; keep the README source table in sync.

## Rules

- Content: only official RSS/Atom feeds and public APIs. Show title, source, date, short snippet
  and a link to the original; never scrape, never store full articles, no API keys.
- Public repo: never commit `android/key.properties`, `*.jks` or anything secret. The release
  keystore is `C:\Users\Albert\keys\news-bucket.jks`. Don't upload signing secrets to GitHub
  yourself: the user runs `powershell -ExecutionPolicy Bypass -File tool/set_release_secrets.ps1`.
- Android gotchas already handled, keep them: `INTERNET` permission in the main
  `AndroidManifest.xml` (release builds need it), core library desugaring (needed by
  flutter_local_notifications), `minSdk >= 24`, notification icon
  `res/drawable/ic_notification.xml` kept from shrinking by `res/raw/keep.xml`.
- Android only. Don't run on Chrome/Windows/web: most feeds are blocked by CORS there.
- Git: author email `albert.rzad@gmail.com`, work on `main`, short English commit messages.
  After a push, wait for CI (`gh run list --workflow CI --limit 1`) to be green. Releases: push a
  tag `v*` → `.github/workflows/release.yml` builds a signed APK and publishes a GitHub release.
- Don't call the app finished until it has been checked on the emulator, screen by screen.
