import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_holy_bible/components/app_theme.dart';
import 'package:the_holy_bible/components/db_helper.dart';
import 'package:the_holy_bible/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set full-screen immersive mode.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await DatabaseHelper.instance.database;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: MainScreen(),
    );
  }
}
