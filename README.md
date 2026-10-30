# News Bucket

A small, personal Android news aggregator built with Flutter. It collects the most interesting
headlines about **Claude / Anthropic**, **AI**, **programming**, **cybersecurity**,
**stocks & ETFs** and **crypto** into one feed.

> Status: early skeleton. See the roadmap below.

## How it works

- Everything runs on the device. There is no backend, no account and no tracking.
- Articles come only from **official RSS/Atom feeds and public APIs** (Hacker News via Algolia,
  DEV.to, arXiv, GitHub releases). Nothing is scraped and no API keys are needed.
- The app shows the title, source, date and a short snippet, and opens the original article in the
  browser. Full article content is never copied or stored.

Sources live in [`assets/sources.json`](assets/sources.json). Add or remove a source by editing
that file.

| Category | Sources |
|---|---|
| Claude | Claude Code releases, Anthropic News & Engineering (community feeds), Hacker News |
| AI | OpenAI, Google AI, Hugging Face, Simon Willison, arXiv, DEV #ai |
| Programming | Hacker News, Lobsters, DEV, GitHub Blog |
| Security | BleepingComputer, The Hacker News, Krebs, Schneier, Sekurak, Niebezpiecznik |
| Stocks & ETFs | CNBC, MarketWatch, ETF.com |
| Crypto | CoinDesk, Cointelegraph, Decrypt |

All content belongs to its respective publishers.

## Development

Requirements: Flutter (stable), Android SDK.

```sh
flutter pub get
flutter analyze
flutter test
flutter run            # on an emulator or a USB-connected phone
flutter build apk      # build an installable APK
dart run tool/check_sources.dart   # fetch every source live and print item counts
```

## Roadmap

- [x] Project skeleton: navigation, light/dark theme, source list, CI
- [x] Data layer: feed parsers (RSS/Atom/RDF/JSON), local cache (drift), refresh
- [x] Feed UI: category and source filters, read/unread, pull-to-refresh, offline cache
- [x] Saved articles, per-source on/off switches, persisted theme
- [ ] Background check with local notifications (e.g. new Claude Code releases)
- [ ] Signed release APKs published to GitHub Releases

## License

[MIT](LICENSE)
