import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'services/notification_service.dart';
import 'services/weather_service.dart'; // ✅ ADDED

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// 🔥 Register background handler
  FirebaseMessaging.onBackgroundMessage(
    NotificationService.firebaseMessagingBackgroundHandler,
  );

  /// 🔔 Init notifications
  await NotificationService.init();

  /// ✅ GET + SEND FCM TOKEN
  await _registerFcmToken();

  runApp(const SkyCastApp());
}

/// ✅ NEW FUNCTION (clean separation)
Future<void> _registerFcmToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM TOKEN: $token");

    if (token != null) {
      await WeatherService.sendFcmToken(token);
    }
  } catch (e) {
    print("Error getting FCM token: $e");
  }
}

class SkyCastApp extends StatelessWidget {
  const SkyCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyCast',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      routes: {
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}