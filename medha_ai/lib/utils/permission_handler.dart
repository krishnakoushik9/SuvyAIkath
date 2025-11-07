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
    // For Android 10 (API 29) and above, we need to request storage permissions differently
    if (isAndroid) {
      // First request storage permission (for Android 10+)
      final storageStatus = await Permission.storage.request();
      
      // Then request manage external storage if needed (for Android 11+)
      if (storageStatus.isGranted) {
        await Permission.manageExternalStorage.request();
      }
      
      // Request other permissions
      final otherPermissions = await [
        Permission.contacts,
        Permission.photos,
        Permission.notification,
      ].request();
      
      // Combine all permission statuses
      return {
        ...otherPermissions,
        Permission.storage: storageStatus,
        Permission.manageExternalStorage: await Permission.manageExternalStorage.status,
      };
    } else {
      // For iOS, request permissions normally
      return await [
        Permission.contacts,
        Permission.storage,
        Permission.photos,
        Permission.notification,
      ].request();
    }
  }

  // Check if all permissions are granted
  static Future<bool> hasAllPermissions() async {
    if (isAndroid) {
      // On Android, we need to check both storage and manage external storage
      final storageGranted = await Permission.storage.isGranted;
      final manageStorageGranted = await Permission.manageExternalStorage.isGranted;
      
      // For Android 10 and below, we only need storage permission
      // For Android 11 and above, we need manage external storage
      final isAndroid11OrHigher = await Permission.storage.isLimited || 
                                 await Permission.storage.isDenied;
      
      final otherPermissions = await Future.wait([
        Permission.contacts.status.then((s) => s.isGranted),
        Permission.photos.status.then((s) => s.isGranted),
        Permission.notification.status.then((s) => s.isGranted),
      ]);
      
      return otherPermissions.every((isGranted) => isGranted) &&
             storageGranted && 
             (!isAndroid11OrHigher || manageStorageGranted);
    } else {
      // For iOS, check permissions normally
      final permissions = await Future.wait([
        Permission.contacts.status.then((s) => s.isGranted),
        Permission.storage.status.then((s) => s.isGranted),
        Permission.photos.status.then((s) => s.isGranted),
        Permission.notification.status.then((s) => s.isGranted),
      ]);
      
      return permissions.every((isGranted) => isGranted);
    }
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
