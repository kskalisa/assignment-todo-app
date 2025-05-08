import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// Todo model class
class Todo {
  final String title;
  final String description;
  final bool done;
  final DateTime createdAt;

  Todo({
    required this.title,
    this.description = '',
    this.done = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? title,
    String? description,
    bool? done,
    DateTime? createdAt,
  }) {
    return Todo(
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'done': done,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      title: map['title'],
      description: map['description'],
      done: map['done'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

// Todo List Notifier
class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier() : super([]);

  void addTodo(Todo todo) {
    state = [...state, todo];
  }

  void updateTodo(int index, Todo updatedTodo) {
    state = [
      ...state.sublist(0, index),
      updatedTodo,
      ...state.sublist(index + 1),
    ];
  }

  void removeTodo(int index) {
    state = [
      ...state.sublist(0, index),
      ...state.sublist(index + 1),
    ];
  }

  void toggleTodo(int index) {
    state = [
      ...state.sublist(0, index),
      state[index].copyWith(done: !state[index].done),
      ...state.sublist(index + 1),
    ];
  }
}

// Provider for TodoList
final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});

// Theme Notifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  Future<void> toggleTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getInt('themeMode');
    if (savedMode != null) {
      state = ThemeMode.values[savedMode];
    }
  }
}

// Provider for Theme
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Filter Provider
enum TodoFilter { all, completed, pending }

final filterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

// Search Provider
final searchProvider = StateProvider<String>((ref) => '');

// Filtered Todos Provider
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final filter = ref.watch(filterProvider);
  final search = ref.watch(searchProvider);
  final todos = ref.watch(todoListProvider);

  var filteredTodos = todos;

  // Apply filter
  switch (filter) {
    case TodoFilter.completed:
      filteredTodos = todos.where((todo) => todo.done).toList();
      break;
    case TodoFilter.pending:
      filteredTodos = todos.where((todo) => !todo.done).toList();
      break;
    case TodoFilter.all:
      break;
  }

  // Apply search
  if (search.isNotEmpty) {
    filteredTodos = filteredTodos.where((todo) {
      final title = todo.title.toLowerCase();
      final description = todo.description.toLowerCase();
      return title.contains(search.toLowerCase()) ||
          description.contains(search.toLowerCase());
    }).toList();
  }

  return filteredTodos;
});