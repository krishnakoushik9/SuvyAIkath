import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  // Check if Android
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  // Check if iOS
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  // Request multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestAppPermissions() async {
    final permissions = await [
      Permission.contacts,
      Permission.storage,
      Permission.photos,
      Permission.notification,
      if (isAndroid) Permission.manageExternalStorage,
    ].request();

    return permissions;
  }

  // Check if all permissions are granted
  static Future<bool> hasAllPermissions() async {
    final permissions = await Future.wait([
      Permission.contacts.status.then((s) => s.isGranted),
      Permission.storage.status.then((s) => s.isGranted),
      Permission.photos.status.then((s) => s.isGranted),
      Permission.notification.status.then((s) => s.isGranted),
      if (isAndroid) Permission.manageExternalStorage.status.then((s) => s.isGranted),
    ]);

    return permissions.every((isGranted) => isGranted);
  }

  // Show a dialog explaining why permissions are needed
  static Future<bool> showPermissionRationale(
      BuildContext context, List<Permission> permissions) async {
    final permissionNames = permissions.map((p) {
      if (p == Permission.contacts) return 'Contacts';
      if (p == Permission.storage) return 'Storage';
      if (p == Permission.photos) return 'Photos';
      if (p == Permission.notification) return 'Notifications';
      if (p == Permission.manageExternalStorage) return 'Manage External Storage';
      return p.toString();
    }).join(', ');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: Text(
            'This app needs the following permissions to function properly:\n\n$permissionNames\n\nPlease grant these permissions in the app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (result == true) {
      await openAppSettings();
    }
    return result ?? false;
  }

  // Request specific permission with rationale
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    final result = await permission.request();
    return result.isGranted;
  }
}
