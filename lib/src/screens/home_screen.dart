import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_todolist/src/state/task_controller.dart';
import 'package:mini_todolist/src/widgets/progress_ring.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _titleError;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onAddPressed() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() { _titleError = 'Title cannot be empty'; });
      return;
    }
    setState(() { _titleError = null; });
    final created = await ref.read(taskControllerProvider.notifier).addTask(title);
    if (created != null) {
      _titleController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "' + created.title + '"'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(taskControllerProvider.notifier).deleteTask(created.id, showUndo: false);
              },
            ),
          ),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(taskControllerProvider.notifier).setQuery(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(taskControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ProgressRing(
                    completed: controller.numDone,
                    total: controller.tasks.length,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PocketTasks',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Add Task',
                        errorText: _titleError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      onSubmitted: (_) => _onAddPressed(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _onAddPressed,
                      child: const Text('Add'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  FilterChip(
                    label: const Text('All'),
                    selected: controller.filter == TaskFilter.all,
                    onSelected: (_) => ref.read(taskControllerProvider.notifier).setFilter(TaskFilter.all),
                  ),
                  FilterChip(
                    label: const Text('Active'),
                    selected: controller.filter == TaskFilter.active,
                    onSelected: (_) => ref.read(taskControllerProvider.notifier).setFilter(TaskFilter.active),
                  ),
                  FilterChip(
                    label: const Text('Done'),
                    selected: controller.filter == TaskFilter.done,
                    onSelected: (_) => ref.read(taskControllerProvider.notifier).setFilter(TaskFilter.done),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: controller.visibleTasks.isEmpty
                    ? const Center(child: Text('No tasks'))
                    : ListView.builder(
                        itemCount: controller.visibleTasks.length,
                        itemBuilder: (context, index) {
                          final task = controller.visibleTasks[index];
                          return Dismissible(
                            key: ValueKey(task.id),
                            background: Container(
                              color: Theme.of(context).colorScheme.errorContainer,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 16),
                              child: const Icon(Icons.delete),
                            ),
                            secondaryBackground: Container(
                              color: Theme.of(context).colorScheme.errorContainer,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete),
                            ),
                            onDismissed: (_) {
                              ref.read(taskControllerProvider.notifier).deleteTask(task.id);
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Deleted "' + task.title + '"'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      ref.read(taskControllerProvider.notifier).undo();
                                    },
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              onTap: () {
                                ref.read(taskControllerProvider.notifier).toggleDone(task.id);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text((task.done ? 'Marked active: ' : 'Completed: ') + task.title),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        ref.read(taskControllerProvider.notifier).undo();
                                      },
                                    ),
                                  ),
                                );
                              },
                              leading: Icon(task.done ? Icons.check_circle : Icons.radio_button_unchecked),
                              title: Text(
                                task.title,
                                style: task.done
                                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
