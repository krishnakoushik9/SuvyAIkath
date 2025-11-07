import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(initSettings);
  }

  static Future<void> showThankYou() async {
    const androidDetails = AndroidNotificationDetails(
      'medha_ai_general',
      'General',
      channelDescription: 'General notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      1001,
      'Team Shasakkta!!',
      'Thank you for testing the Prototype 1',
      details,
    );
  }
}
