# Local Chat App

Local-only chat app built with Flutter. No backend, no network calls — all data stored on-device in SQLite. Provider for state management.

## Stack
Flutter · Dart · sqflite · Provider · intl · shared_preferences

## Features

| Screen | Features |
|--------|----------|
| **Home** | Contact list, last message preview, unread count badge, add contact (bottom sheet with avatar colour picker), long-press to delete |
| **Chat** | Message bubbles (sent/received), timestamps, read receipts (✓ / ✓✓), auto-scroll on new message, simulated reply |
| **Search** | Full-text search across all messages, results grouped by contact with timestamp |
| **Settings** | Display name (persisted via SharedPreferences), about/privacy info |

## Architecture

```
lib/
├── main.dart                  # MultiProvider setup, Material 3 theme (light + dark)
├── models/
│   ├── contact.dart           # Contact model with copyWith
│   └── message.dart           # Message model with copyWith
├── db/
│   └── db_helper.dart         # SQLite: schema, CRUD, full-text search query
├── providers/
│   ├── contacts_provider.dart # ChangeNotifier: contact list + unread counts
│   └── chat_provider.dart     # ChangeNotifier: messages for active chat
├── screens/
│   ├── home_screen.dart       # Contact list + add/delete
│   ├── chat_screen.dart       # Message bubbles + input + auto-scroll
│   ├── search_screen.dart     # Full-text search
│   └── settings_screen.dart   # Display name + about
└── widgets/
    ├── contact_tile.dart       # Last message preview + unread badge
    └── message_bubble.dart     # Sent/received bubble + read receipt icon
```

## SQLite Schema

```sql
CREATE TABLE contacts (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  name         TEXT    NOT NULL,
  avatar_color INTEGER NOT NULL,
  created_at   TEXT    NOT NULL
);

CREATE TABLE messages (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  contact_id  INTEGER NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
  text        TEXT    NOT NULL,
  is_from_me  INTEGER NOT NULL DEFAULT 0,
  is_read     INTEGER NOT NULL DEFAULT 0,
  created_at  TEXT    NOT NULL
);
```

## Run

```bash
flutter pub get
flutter run
```

Runs on Android, iOS, and macOS (desktop).

## Design
- Material 3 with dynamic colour seeded from `#6366F1`
- Auto light/dark mode based on system preference
- Animated send button (scale on text input)
- Smooth scroll to latest message
