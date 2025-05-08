import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_todo_app/providers/providers.dart';

class TodoDetailsScreen extends ConsumerStatefulWidget {
  final Todo todo;
  final int index;

  const TodoDetailsScreen({
    super.key,
    required this.todo,
    required this.index,
  });

  @override
  ConsumerState<TodoDetailsScreen> createState() => _TodoDetailsScreenState();
}

class _TodoDetailsScreenState extends ConsumerState<TodoDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;

  @override
  void initState() {
    super.initState();
    _title = widget.todo.title;
    _description = widget.todo.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Creation date
              Text(
                "Created At: ${widget.todo.createdAt}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Title field
              const Text(
                "Title",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Title required' : null,
                onSaved: (value) => _title = value!.trim(),
              ),
              const SizedBox(height: 24),

              // Description field
              const Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _description,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter full description',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _description = value!.trim(),
              ),
              const SizedBox(height: 32),

              // Save Changes Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ref.read(todoListProvider.notifier).updateTodo(
                      widget.index,
                      widget.todo.copyWith(
                        title: _title,
                        description: _description,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}