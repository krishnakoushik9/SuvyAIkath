import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<void> requestAll() async {
    try {
      // Notifications (Android 13+)
      await Permission.notification.request();
    } catch (_) {}

    try {
      // Location (coarse/fine)
      await Permission.location.request();
    } catch (_) {}

    try {
      // Storage (legacy API on < Android 11)
      await Permission.storage.request();
    } catch (_) {}

    try {
      // Manage external storage (Android 11+)
      if (Platform.isAndroid) {
        await Permission.manageExternalStorage.request();
      }
    } catch (_) {}
  }
}
