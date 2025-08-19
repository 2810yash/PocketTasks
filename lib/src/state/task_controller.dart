import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_todolist/src/models/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const String kStorageKey = 'pocket_tasks_v1';
const Uuid _uuid = Uuid();

enum TaskFilter { all, active, done }

class TaskState {
  final List<Task> tasks;
  final String query;
  final TaskFilter filter;
  final List<Task> history; // last mutated list for undo

  const TaskState({
    required this.tasks,
    required this.query,
    required this.filter,
    required this.history,
  });

  List<Task> get visibleTasks {
    Iterable<Task> result = tasks;
    if (filter == TaskFilter.active) {
      result = result.where((t) => !t.done);
    } else if (filter == TaskFilter.done) {
      result = result.where((t) => t.done);
    }
    final String trimmed = query.trim().toLowerCase();
    if (trimmed.isNotEmpty) {
      result = result.where((t) => t.title.toLowerCase().contains(trimmed));
    }
    return result.toList(growable: false);
  }

  int get numDone => tasks.where((t) => t.done).length;

  TaskState copyWith({
    List<Task>? tasks,
    String? query,
    TaskFilter? filter,
    List<Task>? history,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      history: history ?? this.history,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  factory TaskState.fromPrefsJson(Map<String, Object?> json) {
    final List<dynamic> raw = (json['tasks'] as List<dynamic>? ?? <dynamic>[]);
    final List<Task> parsed = raw
        .map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return TaskState(tasks: parsed, query: '', filter: TaskFilter.all, history: <Task>[]);
  }
}

final taskControllerProvider = StateNotifierProvider<TaskController, TaskState>((ref) {
  return TaskController();
});

class TaskController extends StateNotifier<TaskState> {
  TaskController()
      : super(const TaskState(tasks: <Task>[], query: '', filter: TaskFilter.all, history: <Task>[])) {
    _load();
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(kStorageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final Map<String, Object?> map = json.decode(raw) as Map<String, Object?>;
      state = TaskState.fromPrefsJson(map);
    } catch (_) {
      // ignore malformed cache
    }
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(kStorageKey, json.encode(state.toJson()));
  }

  Future<Task?> addTask(String title) async {
    final Task created = Task(id: _uuid.v4(), title: title, createdAt: DateTime.now());
    final List<Task> next = <Task>[created, ...state.tasks];
    state = state.copyWith(history: state.tasks, tasks: next);
    await _persist();
    return created;
  }

  Future<void> deleteTask(String id, {bool showUndo = true}) async {
    final List<Task> next = state.tasks.where((t) => t.id != id).toList();
    state = state.copyWith(history: state.tasks, tasks: next);
    await _persist();
  }

  Future<void> toggleDone(String id) async {
    final List<Task> next = state.tasks
        .map((t) => t.id == id ? t.copyWith(done: !t.done) : t)
        .toList(growable: false);
    state = state.copyWith(history: state.tasks, tasks: next);
    await _persist();
  }

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> undo() async {
    if (listEquals(state.history, state.tasks)) return;
    final List<Task> prev = state.history;
    state = state.copyWith(history: state.tasks, tasks: prev);
    await _persist();
  }
}


