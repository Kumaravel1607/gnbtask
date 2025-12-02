import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    // Web doesn't need runtime permissions, browser handles it
    if (kIsWeb) return true;

    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // Open app settings so user can enable it manually
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Request photo library/gallery permission
  Future<bool> requestGalleryPermission() async {
    // Web doesn't need runtime permissions
    if (kIsWeb) return true;

    final status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.photos.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    // Web doesn't need runtime permissions
    if (kIsWeb) return true;

    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    if (kIsWeb) return true;
    return await Permission.camera.isGranted;
  }

  /// Check if gallery permission is granted
  Future<bool> isGalleryPermissionGranted() async {
    if (kIsWeb) return true;
    return await Permission.photos.isGranted;
  }

  /// Open app settings for manual permission management
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
