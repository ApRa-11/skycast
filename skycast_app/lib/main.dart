import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const SkyCastApp());
}

class SkyCastApp extends StatelessWidget {
  const SkyCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyCast',
      theme: ThemeData(primarySwatch: Colors.blue),

      // 👇 keep HomeScreen as main
      home: const HomeScreen(),

      // 👇 ADD THIS (important for navigation)
      routes: {
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}