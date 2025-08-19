# PocketTasks Mini

PocketTasks is a tiny, single‑screen task manager that demonstrates clean state management, offline persistence, undo logic, debounced search, and a small custom UI element.

## Features

- Add tasks with inline validation
- With Search option
- Filter chips: All / Active / Done
- Tap to toggle done (with Undo via SnackBar)
- Swipe to delete (with Undo)
- Circular progress ring showing completed/total
- Light & Dark themes according to your device
- Efficient with 100+ tasks

## Architecture

- Data model: `Task { id, title, done, createdAt }`
- State management: Riverpod (`StateNotifier`) with immutable `TaskState`
- Persistence: `shared_preferences` storing the task list as JSON
  - Storage key: `pocket_tasks_v1`
- Undo: Each mutation stores the previous `tasks` list in `history`; `undo()` swaps current with previous and persists
- Search & filter: `visibleTasks` computes the list from `tasks` using `query` and `TaskFilter`
- CustomPainter: `ProgressRing` draws a background circle + progress arc with center label `done/total`

## Project structure (high‑level)

```
lib/
  main.dart                      # App bootstrap, theming
  src/
    models/task_model.dart       # Task model with JSON + copyWith
    screens/home_screen.dart     # Single screen UI and interactions
    state/task_controller.dart   # Riverpod StateNotifier, persistence, undo
    widgets/progress_ring.dart   # CustomPainter progress ring
```

## Getting started

1. Install Flutter (stable) and platform toolchains.
2. Get packages:

   ```bash
   flutter pub get
   ```

3. Run the app on a device/emulator:

   ```bash
   flutter run
   ```

## Implementation notes

- `MainScreen` uses two text fields (Add + Search). Search updates state via a 300 ms `Timer` debounce.
- Filters are `FilterChip`s bound to `TaskFilter` in state.
- `Dismissible` provides swipe‑to‑delete; SnackBars include an Undo action that calls `undo()`.
- Persistence reads on startup and writes after each mutation to keep storage consistent.
- The progress ring computes `progress = completed / total` and clamps to 0–1 to avoid rendering glitches.

## Dependencies

- `flutter_riverpod`
- `shared_preferences`
- `uuid`

