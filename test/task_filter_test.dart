import 'package:flutter_test/flutter_test.dart';
import 'package:mini_todolist/src/models/task_model.dart';
import 'package:mini_todolist/src/state/task_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('search and filter combinations', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = TaskController();

    // Seed tasks without touching persistence
    controller.state = controller.state.copyWith(tasks: <Task>[
      Task(id: '1', title: 'Buy groceries', done: true, createdAt: DateTime(2021)),
      Task(id: '2', title: 'Walk the dog', done: false, createdAt: DateTime(2021)),
      Task(id: '3', title: 'Call Alice', done: false, createdAt: DateTime(2021)),
      Task(id: '4', title: 'Call Bob', done: true, createdAt: DateTime(2021)),
    ]);

    // All
    controller.setFilter(TaskFilter.all);
    controller.setQuery('');
    expect(controller.state.visibleTasks.length, 4);

    // Active only
    controller.setFilter(TaskFilter.active);
    expect(controller.state.visibleTasks.map((t) => t.id), ['2', '3']);

    // Done only
    controller.setFilter(TaskFilter.done);
    expect(controller.state.visibleTasks.map((t) => t.id), ['1', '4']);

    // Query filter
    controller.setFilter(TaskFilter.all);
    controller.setQuery('call');
    expect(controller.state.visibleTasks.map((t) => t.id), ['3', '4']);

    // Query + status
    controller.setFilter(TaskFilter.active);
    expect(controller.state.visibleTasks.map((t) => t.id), ['3']);
  });
}


