import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'features/receipt/presentation/pages/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // สำหรับ Windows/Linux/macOS: ให้ sqflite_common_ffi ใช้ databaseFactoryFfi
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: DashboardPage(
        themeMode: _themeMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}
