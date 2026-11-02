# News Bucket: notes for Claude

Personal Android news aggregator in Flutter. Nine categories: AI (the Claude/Anthropic sources
belong here on purpose, the user merged the two), Programming, Security, Stocks & ETFs, Crypto,
Gaming, Books (mainly fantasy, crime fiction, popular science), Conspiracies (UFOs, mysteries and
government ones like 9/11 or JFK, plus debunkers), True Crime. Each can be hidden in Settings.
Used by the owner and two friends; APKs are installed by hand from GitHub Releases, no Play
Store, no backend. Public repo: https://github.com/albertrzad18/news-bucket

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
  first-run screen: tap "Use without an account". To find tap targets, `adb shell uiautomator dump`
  works: Flutter semantics appear as `content-desc` with bounds (tooltips, chip labels, tile text).
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
  JSON parsers (HN Algolia, DEV), drift DB (`articles`, `source_states`; 30-day retention, saved
  kept forever), `news_repository.dart`. `lib/features/` feed, saved, settings, notifications.
- The Feed has swipeable category tabs (`TabBar`/`TabBarView`): All plus one per category, the
  selected tab tinted in its category colour. `feedArticlesProvider` is a family keyed by
  `NewsCategory?` (null = All). `FeedFilter` (`feed_providers.dart`) holds what all tabs share:
  sources and publication period (`FeedPeriod`) from `feed_filter_sheet.dart` (which lists the open
  tab's sources; a selected source only narrows its own category's tab), and a search field in the
  app bar (300 ms debounce; every word must match title or snippet via SQL `LIKE`, ASCII-only case
  folding). Search and the period filter apply to the Feed tab only. Dates in the future are stored
  as the fetch time so they can't pin an article to the top.
- Hidden categories (`category_settings.dart`, prefs key `hidden_categories`) lose their tab and
  their place in All, and their sources are neither refreshed nor checked for notifications
  (`enabledSourcesProvider`, `runNewsCheck`). At least one category stays visible. The Feed
  rebuilds its `TabController` when the visible set changes. A new category needs an enum value
  in `news_category.dart` and light/dark colours in `NbColors`; no DB migration (it's a text
  column).
- DB schema version 3. Users update by installing a new APK over the old one, so every schema
  change needs a step in `AppDatabase.migration.onUpgrade` and a check in
  `test/data/migration_test.dart` (it starts from the v1 schema shipped in v0.1.0). v2 dropped
  `image_url`, v3 moved category `claude` to `ai`.
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
- Sources live in `assets/sources.json`; keep the README source table in sync, except the
  Conspiracies category: the user doesn't want it mentioned in the README at all (no row, no
  name in the intro or tab list, and the source count is "over 50" so it doesn't add up to it).

## Rules

- Content: only official RSS/Atom feeds and public APIs. Show title, source, date, short snippet
  and a link to the original; never scrape, never store full articles, no API keys.
- No images at all: don't parse, store or show thumbnails. The user wants every card to look the
  same.
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

## Status

- v0.1.0 released 2026-10-31 (schema 1, still had the Claude category and images).
- v0.2.0 released 2026-11-01 (schema 3): redesign, category tabs, search and date filter, no
  images, no notification sources by default. The next release tag will be v0.3.0.
- The visual redesign ("paper on a desk") is on `main`: explicit light/dark `ColorScheme`s plus
  `NbColors`/`NbText` theme extensions in `app_theme.dart`, bundled variable fonts Literata
  (headlines) and Public Sans (UI) in `assets/fonts/`. Change font weights with
  `TextStyle.withWeight()`, not `copyWith(fontWeight:)`, because the fonts are variable. One
  ink-blue accent marks state only; no images, emoji, gradients or shadows on content. Shared
  widgets live in `lib/core/widgets/` (`EmptyState`, `CategoryMarker`).
