# Flutter Hive Offline Posts

A Flutter posts app that fetches JSONPlaceholder posts, caches them with Hive, and keeps favorites available offline.

[Open the Flutter project](flutter-hive-offline-posts/README.md)

This project implements Section 5, Part 3 (Favorites Box), with Android emulator evidence for the online and offline scenarios.

## Features

- Fetch posts from the API and cache them locally.
- Read cached posts when the network is unavailable.
- Save and remove favorites with live star icons and a count badge.
- Keep favorites across refreshes and app restarts in a separate box.
- Pull to refresh and view loading, error, and empty states.

## Data flow

```text
INTERNET â†’ API â†’ Hive postsBox â†’ ListView
                         star tap â†’ favoritesBox â†’ Favorites screen
```

## Project structure

```text
lib/
â”œâ”€â”€ main.dart                     Initialize Hive and launch the app
â”œâ”€â”€ models/
â”‚   â”œâ”€â”€ post_model.dart           Hive model and JSON conversion
â”‚   â””â”€â”€ post_model.g.dart         Hive type adapter
â”œâ”€â”€ services/
â”‚   â”œâ”€â”€ post_service.dart        Fetch and cache posts; offline fallback
â”‚   â””â”€â”€ favorites_service.dart   Save, remove, and listen to favorites
â”œâ”€â”€ widgets/
â”‚   â””â”€â”€ post_card.dart            Shared post card and star
â””â”€â”€ screens/
    â”œâ”€â”€ posts_screen.dart         Posts, refresh, badge and navigation
    â””â”€â”€ favorites_screen.dart     Live favorites list and empty state
test/
â””â”€â”€ favorites_test.dart           Hive and widget checks
screenshots/                      Evidence captures
```

## SharedPreferences vs Hive

| | SharedPreferences | Hive |
|---|---|---|
| Best for | Small settings and primitive values | Local collections and structured objects |
| Data | Key-value primitives | Boxes with typed adapters and objects |
| Listening | Typically managed by app state | Box listenables update widgets |
| Offline | Local settings | Local records and cached data |

## How Favorites Work

Each post's ID is its key in `favoritesBox`. `put` adds a favorite, `containsKey` checks it, and `delete` removes it. A fresh `Post` copy is saved because a `HiveObject` can belong to only one box; the original is already stored in `postsBox`. The separate box also survives `postsBox.clear()` during refresh. `ValueListenableBuilder` listens to the favorites box so stars, the badge, and the favorites list update immediately.

## Getting Started

Install Flutter and a suitable device or emulator. From the directory containing this README:

```sh
cd flutter-hive-offline-posts
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The adapter is included in the project; generation is useful when the model changes. If platform folders are absent, run `flutter create --platforms android,web,windows .` first.

## Screenshots

Captured on an Android emulator. The online test used the Cypress JSONPlaceholder mirror because this network could not reach the default endpoint. The log images reproduce output from Android logcat.

To use the same endpoint for a run:

```sh
flutter run --dart-define=POSTS_API_URL=https://jsonplaceholder.cypress.io/posts
```

| # | Feature or action | Capture |
|---|---|---|
| 1 | Posts loaded online with outlined stars | <img src="flutter-hive-offline-posts/screenshots/1_posts_online.png" width="285" alt="Posts loaded online with outlined stars"> |
| 2 | API log confirming 100 posts cached to Hive | <img src="flutter-hive-offline-posts/screenshots/2_console_api.png" width="620" alt="API log confirming 100 posts cached to Hive"> |
| 3 | Three saved posts with filled stars and badge count | <img src="flutter-hive-offline-posts/screenshots/3_stars.png" width="285" alt="Three saved posts with filled stars and badge count"> |
| 4 | Saved posts opened from the AppBar Favorites button | <img src="flutter-hive-offline-posts/screenshots/4_favorites_screen.png" width="285" alt="Saved posts opened from the AppBar Favorites button"> |
| 5 | Empty Favorites screen | <img src="flutter-hive-offline-posts/screenshots/5_empty.png" width="285" alt="Empty Favorites screen"> |
| 6 | Posts restored from Hive in airplane mode, with log output | <img src="flutter-hive-offline-posts/screenshots/6_offline_posts.png" width="285" alt="Posts restored from Hive in airplane mode, with log output"> |
| 7 | The same three favorites after an offline restart | <img src="flutter-hive-offline-posts/screenshots/7_offline_favorites.png" width="285" alt="The same three favorites after an offline restart"> |
| 8 | First launch in airplane mode with no cached data | <img src="flutter-hive-offline-posts/screenshots/8_no_cache_error.png" width="285" alt="First launch in airplane mode with no cached data"> |
| 9 | Favorite removed, with an outlined star and updated badge | <img src="flutter-hive-offline-posts/screenshots/9_removed_favorite.png" width="285" alt="Favorite removed, with an outlined star and updated badge"> |

## Offline test steps

| Action | Expected result |
|---|---|
| Run online and load posts, then mark several favorites. | Posts appear, API cache message is logged, and stars fill. |
| Close the app, enable airplane mode with Wi-Fi off, and reopen it. | Cached posts appear and the offline Hive message is logged. |
| Open Favorites after the offline restart. | The same three saved posts remain visible. |
| Clear app data or reinstall, then start in airplane mode. | The no-internet and no-cached-data error appears. |

## Packages used

- `http`: API requests
- `hive` and `hive_flutter`: local storage and Flutter integration
- `hive_generator` and `build_runner`: adapter generation
- `flutter_test`: unit and widget tests
