import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_todo_app/ui/login_screen.dart';
import 'package:assignment_todo_app/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Load saved theme
    Future.microtask(() => ref.read(themeProvider.notifier).loadTheme());
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.indigo,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.indigoAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo[300],
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.indigoAccent[200],
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo[800],
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo[800],
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: themeMode,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}