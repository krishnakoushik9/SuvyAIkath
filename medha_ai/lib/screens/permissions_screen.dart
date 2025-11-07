import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/permission_handler.dart' as app_permissions;


class PermissionsScreen extends StatefulWidget {
  final VoidCallback? onPermissionsGranted;

  const PermissionsScreen({super.key, this.onPermissionsGranted});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isLoading = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasAll = await app_permissions.AppPermissions.hasAllPermissions();
    if (hasAll && mounted) {
      widget.onPermissionsGranted?.call();
      return;
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _status = 'Requesting permissions...';
    });

    try {
      final results = await app_permissions.AppPermissions.requestAppPermissions();
      
      // Check if all permissions are granted
      final allGranted = await app_permissions.AppPermissions.hasAllPermissions();
      
      if (allGranted) {
        if (mounted) {
          widget.onPermissionsGranted?.call();
        }
      } else {
        // Check storage permissions specifically
        final storageStatus = await Permission.storage.status;
        final manageStorageStatus = await Permission.manageExternalStorage.status;
        final isAndroid = defaultTargetPlatform == TargetPlatform.android;
        
        String statusMessage = '';
        
        if (isAndroid) {
          if (!storageStatus.isGranted) {
            statusMessage = 'Storage permission is required to save and access your study materials. ';
          } 
          if (!manageStorageStatus.isGranted && storageStatus.isGranted) {
            // Only show manage storage message if storage is granted but manage is not
            statusMessage += '\n\nTo manage your study files, please grant "Manage Storage" permission. ';
          }
          
          statusMessage += '\n\nPlease enable these permissions in your device settings to continue.';
        } else {
          // For iOS
          final denied = results.entries
              .where((e) => !e.value.isGranted)
              .map((e) {
                switch (e.key) {
                  case Permission.contacts: return 'Contacts';
                  case Permission.storage: return 'Storage';
                  case Permission.photos: return 'Photos';
                  case Permission.notification: return 'Notifications';
                  default: return e.key.toString();
                }
              })
              .join(', ');
              
          statusMessage = 'The following permissions are required: $denied.\n\nPlease enable them in your device settings.';
        }

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Permissions Required'),
              content: Text(statusMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error requesting permissions: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions Required'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'App Permissions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'To provide the best experience, the app requires the following permissions:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildPermissionItem(Icons.contacts, 'Contacts', 'For syncing with your contacts'),
            _buildPermissionItem(Icons.photo_library, 'Photos & Media', 'To save and access media files'),
            _buildPermissionItem(Icons.sd_storage, 'Storage', 'To store app data and files'),
            _buildPermissionItem(Icons.notifications, 'Notifications', 'For important updates and alerts'),
            const Spacer(),
            if (_status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _status,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _requestPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'GRANT PERMISSIONS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text('Open App Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
