import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_todo_app/providers/providers.dart';
import 'details.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const HomeScreen({super.key, required this.userEmail});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      ref.read(searchProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _changeFilter(TodoFilter filter) {
    ref.read(filterProvider.notifier).state = filter;
  }

  Widget buildTodoItem(Todo todo, int index, BuildContext context) {
    return Dismissible(
      key: Key('${todo.title}$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(todoListProvider.notifier).removeTodo(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todo deleted')),
        );
      },
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoDetailsScreen(
                todo: todo,
                index: index,
              ),
            ),
          );
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Todo?'),
              content: const Text('Are you sure you want to delete this todo?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(todoListProvider.notifier).removeTodo(index);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Todo deleted')),
                    );
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        leading: Checkbox(
          value: todo.done,
          onChanged: (value) {
            ref.read(todoListProvider.notifier).toggleTodo(index);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.done ? TextDecoration.lineThrough : null,
            color: todo.done ? Colors.grey : Theme.of(context).textTheme.titleMedium?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          todo.description,
          style: TextStyle(
            color: todo.done ? Colors.grey : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = ref.watch(filteredTodosProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckMe App'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_4),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Theme'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Light Theme'),
                        leading: Radio<ThemeMode>(
                          value: ThemeMode.light,
                          groupValue: themeMode,
                          onChanged: (value) {
                            ref.read(themeProvider.notifier).toggleTheme(value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Dark Theme'),
                        leading: Radio<ThemeMode>(
                          value: ThemeMode.dark,
                          groupValue: themeMode,
                          onChanged: (value) {
                            ref.read(themeProvider.notifier).toggleTheme(value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('System Default'),
                        leading: Radio<ThemeMode>(
                          value: ThemeMode.system,
                          groupValue: themeMode,
                          onChanged: (value) {
                            ref.read(themeProvider.notifier).toggleTheme(value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 10),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(context).primaryColor,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              onTap: (index) {
                switch (index) {
                  case 0:
                    _changeFilter(TodoFilter.all);
                    break;
                  case 1:
                    _changeFilter(TodoFilter.completed);
                    break;
                  case 2:
                    _changeFilter(TodoFilter.pending);
                    break;
                }
              },
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Completed'),
                Tab(text: 'Pending'),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Welcome, ${widget.userEmail.split('@')[0]} 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '🔎 Search todo....',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTodoList(filteredTodos),
                  _buildTodoList(filteredTodos),
                  _buildTodoList(filteredTodos),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: TodoForm(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (todos.isEmpty) {
      return const Center(child: Text('No todos'));
    } else {
      return ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          final realIndex = ref.read(todoListProvider).indexWhere((t) => t.title == todo.title);
          return buildTodoItem(todo, realIndex, context);
        },
      );
    }
  }
}

class TodoForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TodoForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: _formKey,
      child: Wrap(
        runSpacing: 12,
        children: [
          const Text('Add New Todo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title *',
              border: const OutlineInputBorder(),
            ),
            validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null,
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.maxFinite, 40),
            ),
            icon: const Icon(Icons.save),
            label: const Text("Save", style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newTodo = Todo(
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                );
                ref.read(todoListProvider.notifier).addTodo(newTodo);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}