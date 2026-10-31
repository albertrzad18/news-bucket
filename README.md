# News Bucket

A small, personal Android news aggregator built with Flutter. It collects the most interesting
headlines about **Claude / Anthropic**, **AI**, **programming**, **cybersecurity**,
**stocks & ETFs** and **crypto** into one feed.

## Features

- One feed from 27 sources, newest first, with category chips and a per-source filter
- Pull to refresh; refreshes on its own when the data is older than 15 minutes
- Works offline from a local cache (articles are kept for 30 days, saved ones forever)
- Save articles for later, share them, read/unread state
- Optional notifications about new articles (by default: Claude Code releases and Anthropic
  news), checked in the background about once an hour
- Light, dark or system theme; every source can be switched off in Settings

## How it works

- Everything runs on the device. There is no backend, no account and no tracking.
- Articles come only from **official RSS/Atom feeds and public APIs** (Hacker News via Algolia,
  DEV.to, arXiv, GitHub releases). Nothing is scraped and no API keys are needed.
- The app shows the title, source, date and a short snippet, and opens the original article in
  the browser. Full article content is never copied or stored.

Sources live in [`assets/sources.json`](assets/sources.json). Add or remove a source by editing
that file (`"notify": true` makes it a default notification source).

| Category | Sources |
|---|---|
| Claude | Claude Code releases, Anthropic News & Engineering (community feeds), Hacker News |
| AI | OpenAI, Google AI, Hugging Face, Simon Willison, arXiv, DEV #ai |
| Programming | Hacker News, Lobsters, DEV, GitHub Blog |
| Security | BleepingComputer, The Hacker News, Krebs, Schneier, Sekurak, Niebezpiecznik |
| Stocks & ETFs | CNBC, MarketWatch, ETF Trends, Seeking Alpha (ETFs) |
| Crypto | CoinDesk, Cointelegraph, Decrypt |

All content belongs to its respective publishers.

## Install

Download the latest `news-bucket-vX.Y.Z.apk` from
[Releases](https://github.com/albertrzad18/news-bucket/releases) on the phone and open it
(Android asks once to allow installing apps from the browser/files app). Updates install over
the previous version.

## Development

Requirements: Flutter (stable), Android SDK (Android Studio installs it), an emulator or a
phone with USB debugging.

```sh
flutter pub get
flutter analyze
flutter test
flutter run                         # on an emulator or a USB-connected phone
dart run tool/check_sources.dart    # fetch every source live and print item counts
dart run build_runner build         # after changing tables in lib/data/db
```

In VS Code, install the recommended Flutter extension, pick a device in the status bar and press
F5 (configurations are in `.vscode/launch.json`).

The app targets Android only. The `web/` folder exists, but most feeds can't be fetched from a
browser (CORS), so the web build is not supported.

Project layout:

```
lib/core/       theme, router, HTTP client, settings, small utils
lib/data/       models, parsers, drift database, repository, providers
lib/features/   feed, saved, settings and notifications screens/logic
assets/         sources.json
tool/           helper scripts
```

## Releases

Release APKs are signed with a private key that is **not** in this repository.

1. Locally, `android/key.properties` (git-ignored) points to the keystore:
   ```properties
   storeFile=C:/path/to/news-bucket.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```
   Keep a backup of the keystore and its password: without the same key, installed apps can't
   be updated.
2. Once, upload the key to the repository secrets used by CI:
   `powershell -ExecutionPolicy Bypass -File tool/set_release_secrets.ps1`
3. To release, bump `version` in `pubspec.yaml` if you like, then push a tag:
   ```sh
   git tag v0.1.0
   git push origin v0.1.0
   ```
   The **Release** workflow tests the app, builds a signed APK and attaches it to a GitHub
   release.

Without `key.properties`, release builds fall back to the debug key.

## License

[MIT](LICENSE)
