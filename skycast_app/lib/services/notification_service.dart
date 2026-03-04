import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// 🔥 Background handler (MUST be top-level)
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    developer.log(
      "Background message received",
      name: "SkyCastNotifications",
    );
  }

  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _requestPermission();
    await _initLocalNotifications();
    await _setupForegroundHandler();
    await _setupBackgroundHandler();
    await _printFCMToken();
  }

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _localNotifications.initialize(initSettings);
  }

  static Future<void> _setupForegroundHandler() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log(
        "Foreground message received",
        name: "SkyCastNotifications",
      );

      if (message.notification != null) {
        _showLocalNotification(
          message.notification!.title ?? "SkyCast Alert",
          message.notification!.body ?? "New weather alert",
        );
      }
    });
  }

  /// ✅ REQUIRED for background notifications
  static Future<void> _setupBackgroundHandler() async {
    FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler);
  }

  static Future<void> _showLocalNotification(
    String title,
    String body,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'skycast_channel',
      'SkyCast Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      title,
      body,
      details,
    );
  }

  static Future<void> _printFCMToken() async {
  try {
    final token = await _messaging.getToken();

    print("🔥 FCM TOKEN: $token");

  } catch (e) {
    print("❌ FCM TOKEN ERROR: $e");
  }
}
}