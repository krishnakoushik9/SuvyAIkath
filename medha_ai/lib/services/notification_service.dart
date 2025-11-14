import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:medha_ai/services/gemini_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final _geminiService = GeminiService();
  final List<String> _memeTemplates = [
    "Why did the student eat their homework? {answer}",
    "What's a computer's favorite snack? {answer}",
    "Why was the math book sad? {answer}",
    "How do trees access the internet? {answer}",
    "Why don't scientists trust atoms? {answer}",
    "What's a programmer's favorite hangout place? {answer}"
  ];

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );
    
    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleKnowledgeBites() async {
    // Cancel any existing notifications
    await _notifications.cancelAll();
    
    // Schedule notifications every 5 minutes
    for (var i = 0; i < 12; i++) { // Schedule for 1 hour (12 * 5 minutes)
      await _notifications.zonedSchedule(
        i, // Unique ID for each notification
        'Knowledge Bite!',
        await _getRandomMemeFact(),
        _nextInstanceOfFiveMinutes(DateTime.now().add(Duration(minutes: i * 5))),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'knowledge_bites',
            'Knowledge Bites',
            channelDescription: 'Fun and educational facts',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfFiveMinutes(DateTime scheduledTime) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
    
    // Ensure we're not in the past
    if (scheduledDate.isBefore(now)) {
      scheduledDate = now.add(const Duration(minutes: 1));
    }
    
    return scheduledDate;
  }

  Future<String> _getRandomMemeFact() async {
    try {
      final random = Random();
      final template = _memeTemplates[random.nextInt(_memeTemplates.length)];
      
      // Get a fun fact from Gemini
      final fact = await _geminiService.generateContent(
        'Give me a short, funny educational fact (max 15 words) about any academic subject. ' 
        'Make it meme-worthy and engaging for students.'
      );
      
      // Get a funny answer from Gemini
      final answer = await _geminiService.generateContent(
        'In one sentence, give a funny answer to this question: ${template.split('{answer}')[0]}',
      );
      
      return '$fact\n\n${template.replaceFirst('{answer}', answer)}';
    } catch (e) {
      // Fallback facts if Gemini fails
      final fallbackFacts = [
        'The shortest war in history was between Britain and Zanzibar in 1896. Zanzibar surrendered after 38 minutes!',
        'A group of flamingos is called a "flamboyance". Now that\'s a fancy party!',
        'Honey never spoils. You could eat 3000-year-old honey and it would still be good!',
        'Octopuses have three hearts. Two pump blood to the gills, while the third pumps it to the rest of the body.',
        'A day on Venus is longer than a year on Venus. Talk about a long Monday!'
      ];
      
      final random = Random();
      return fallbackFacts[random.nextInt(fallbackFacts.length)];
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
