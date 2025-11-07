import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  // Check if Android
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  // Check if iOS
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  // Request only essential permissions
  static Future<Map<Permission, PermissionStatus>> requestAppPermissions() async {
    // Only request essential permissions
    final permissions = await [
      Permission.notification,
      if (isIOS) Permission.photos, // Only request photos on iOS if needed
    ].request();
    
    return permissions;
  }

  // Check if all essential permissions are granted
  static Future<bool> hasAllPermissions() async {
    final permissions = await Future.wait([
      Permission.notification.status.then((s) => s.isGranted),
      if (isIOS) Permission.photos.status.then((s) => s.isGranted),
    ]);
    
    return permissions.every((isGranted) => isGranted);
  }

  // Show permission rationale dialog
  static Future<bool> showPermissionRationale(
      BuildContext context, String permission) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('$permission Permission'),
            content: Text(
                'This app needs $permission permission to function properly.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Deny'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Settings'),
              ),
            ],
          ),
        ) ??
        false;
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
