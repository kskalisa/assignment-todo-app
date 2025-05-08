// providers/todo_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final todoProvider = StateNotifierProvider<TodoNotifier, List<String>>((ref) => TodoNotifier());

class TodoNotifier extends StateNotifier<List<String>> {
  TodoNotifier() : super([]);

  void add(String task) {
    if (task.isNotEmpty) {
      state = [...state, task];
    }
  }

  void remove(String task) {
    state = state.where((t) => t != task).toList();
  }
}