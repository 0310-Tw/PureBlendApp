import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'device_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DeviceService _deviceService = DeviceService();

  Future<void> initialize() async {
    await _requestPermission();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _registerCurrentToken();
    _listenForTokenRefresh();
    _listenForegroundMessages();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _registerCurrentToken() async {
    final token = await _messaging.getToken();

    if (token == null || token.isEmpty) return;

    await _deviceService.registerDeviceToken(
      fcmToken: token,
      platform: _platformName(),
    );
  }

  void _listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      try {
        await _deviceService.registerDeviceToken(
          fcmToken: newToken,
          platform: _platformName(),
        );
      } catch (e) {
        debugPrint('Failed to refresh device token: $e');
      }
    });
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message title: ${message.notification?.title}');
      debugPrint('Foreground message body: ${message.notification?.body}');
      debugPrint('Foreground message data: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened app: ${message.data}');
    });
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }
}