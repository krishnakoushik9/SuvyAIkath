import 'package:flutter/material.dart';
import 'package:medha_ai/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager extends StatefulWidget {
  final Widget child;
  
  const NotificationManager({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _NotificationManagerState createState() => _NotificationManagerState();
}

class _NotificationManagerState extends State<NotificationManager> {
  final _notificationService = NotificationService();
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadNotificationPreference();
  }

  Future<void> _initNotifications() async {
    await _notificationService.initialize();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
    
    if (_notificationsEnabled) {
      await _notificationService.scheduleKnowledgeBites();
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    
    setState(() {
      _notificationsEnabled = value;
    });

    if (value) {
      await _notificationService.scheduleKnowledgeBites();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Knowledge bites enabled! You\'ll receive fun facts every 5 minutes.')),
      );
    } else {
      await _notificationService.cancelAllNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Knowledge bites disabled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<NotificationRequest>(
      onNotification: (notification) {
        if (notification.enable != null) {
          _toggleNotifications(notification.enable!);
        }
        return true;
      },
      child: widget.child,
    );
  }
}

class NotificationRequest extends Notification {
  final bool? enable;
  
  const NotificationRequest({this.enable});
}

// Helper widget to request notification changes
class NotificationToggle extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  
  const NotificationToggle({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Enable Knowledge Bites'),
      subtitle: const Text('Get fun educational facts every 5 minutes'),
      value: value,
      onChanged: onChanged,
      secondary: const Icon(Icons.notifications_active),
    );
  }
}
