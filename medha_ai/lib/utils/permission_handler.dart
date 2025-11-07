import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:permission_handler/permission_handler.dart' hide PermissionStatusExtension;

// Extension to handle permission status without conflicts
extension _PermissionStatusExtension on PermissionStatus {
  bool get isGranted => this == PermissionStatus.granted;
  bool get isDenied => this == PermissionStatus.denied;
  bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;
  bool get isRestricted => this == PermissionStatus.restricted;
  bool get isLimited => this == PermissionStatus.limited;
}

class AppPermissions {

class AppPermissions {
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
      Permission.contacts.isGranted,
      Permission.storage.isGranted,
      Permission.photos.isGranted,
      Permission.notification.isGranted,
      if (isAndroid) Permission.manageExternalStorage.isGranted,
    ]);

    return permissions.every((isGranted) => isGranted == true);
  }

  // Show a dialog explaining why permissions are needed
  static Future<bool> showPermissionRationale(
      BuildContext context, List<Permission> permissions) async {
    final permissionNames = permissions.map((p) {
      switch (p) {
        case Permission.contacts:
          return 'Contacts';
        case Permission.storage:
          return 'Storage';
        case Permission.photos:
          return 'Photos';
        case Permission.notification:
          return 'Notifications';
        case Permission.manageExternalStorage:
          return 'Manage External Storage';
        default:
          return p.toString();
      }
    }).join(', ');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: Text(
            'This app needs the following permissions to function properly:\n\n$permissionNames\n\nPlease grant these permissions in the app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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

  // Check if Android
  static bool get isAndroid =>
      defaultTargetPlatform == TargetPlatform.android;

  // Check if iOS
  static bool get isIOS =>
      defaultTargetPlatform == TargetPlatform.iOS;

  // Request specific permission with rationale
  static Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    }

    final status = await permission.request();
    return status.isGranted;
  }
}

// Extension to handle permission status
extension PermissionStatusExtension on PermissionStatus {
  bool get isGranted => this == PermissionStatus.granted;
  bool get isDenied => this == PermissionStatus.denied;
  bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;
  bool get isRestricted => this == PermissionStatus.restricted;
  bool get isLimited => this == PermissionStatus.limited;
}
