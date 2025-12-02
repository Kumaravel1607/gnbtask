import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gnbtask/Screens/Property_detail_screen.dart';

import 'package:gnbtask/main.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // --- FIX: Initialize Local Notifications ---
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Ensure this icon exists

    // iOS Settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle foreground notification click
        if (response.payload != null) {
          _navigateToId(response.payload!);
        }
      },
    );
    // -------------------------------------------

    // Request Permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showForegroundNotification(message);
    });

    // Background/Terminated Logic
    _setupInteractedMessage();
  }

  Future<void> _setupInteractedMessage() async {
    // Terminated State
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      _handleMessageNavigation(initialMessage);
    }

    // Background State
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);
  }

  void _handleMessageNavigation(RemoteMessage message) {
    if (message.data.containsKey('property_id')) {
      _navigateToId(message.data['property_id']);
    }
  }

  // Helper to centralize navigation
  void _navigateToId(String propertyId) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        // NOW this works because we updated the constructor!
        builder: (context) => PropertyDetailScreen(propertyId: propertyId),
      ),
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      // Pass the ID as payload so clicking the popup works
      payload: message.data['property_id'],
    );
  }

  // Topic subscription methods for sending notifications to all users
  Future<void> subscribeToAllProperties() async {
    try {
      await _firebaseMessaging.subscribeToTopic('all_users');
      print('✅ Subscribed to all_users topic');
    } catch (e) {
      print('❌ Error subscribing to all_users topic: $e');
      // Don't throw error, just log it - app should continue working
    }
  }

  Future<void> unsubscribeFromAllProperties() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('all_users');
      print('✅ Unsubscribed from all_users topic');
    } catch (e) {
      print('❌ Error unsubscribing from all_users topic: $e');
    }
  }

  Future<void> subscribeToPropertyUpdates(String propertyId) async {
    try {
      await _firebaseMessaging.subscribeToTopic('property_$propertyId');
      print('✅ Subscribed to property_$propertyId topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromPropertyUpdates(String propertyId) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('property_$propertyId');
      print('✅ Unsubscribed from property_$propertyId topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  // Get FCM token for sending direct notifications
  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }
}
