import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ran_talk/Model/DefaultData.dart';
import 'package:ran_talk/firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const notificationColor = Color.fromRGBO(49, 130, 246, 1);

class Messaging {
  static late NotificationSettings _settings;
  static late FirebaseMessaging _messaging;
  static const _androidChannelId = 'OurChurchMessagingChannel';
  static const _androidChannelName = 'OurChurchMessagingChannel';
  static const _androidChannelDescription = 'OurChurchMessagingChannel';
  static const _androidTicker = 'OurChurchTicker';

  static Future init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
          onDidReceiveLocalNotification: _onIOSDidReceiveLocalNotification),
    );

    // 로컬 푸시 알림 초기화
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
            _androidChannelId, _androidChannelName,
            description: _androidChannelDescription,
            importance: Importance.max));

    _messaging = FirebaseMessaging.instance;
    _settings = await _messaging.requestPermission(
      badge: true,
      alert: true,
      sound: true,
    );

    // Foreground에 있는 동안 메세지 처리 핸들러 등록
    FirebaseMessaging.onMessage.listen(_handleDataRemoteMessage);
  }

  static Future<String?> getPushToken() async {
    try {
      return await _messaging.getToken();
    } catch (error) {
      return null;
    }
  }

  static bool checkPermission() {
    AuthorizationStatus status = _settings.authorizationStatus;

    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional) {
      return true;
    } else {
      return false;
    }
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle the notification response here
    print('Notification response received: ${response.payload}');
  }

  static void _onIOSDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    // Handle the notification here
    _showMessage(id.toString(), title, body);
  }

  static void registerBackgroundMessageHandler() {
    if (Platform.isIOS) {
      return FirebaseMessaging.onBackgroundMessage(_handleDataRemoteMessage);
    }
  }

  static Future<void> _showMessage(
      String id, String? title, String? body) async {
    if (!Defaultdata.allowsNotification) return;

    const NotificationDetails notificationDetail = NotificationDetails(
        android: AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      color: notificationColor,
      channelDescription: _androidChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: _androidTicker,
    ));

    return _show(id, title, body, notificationDetail);
  }

  static Future<void> _show(String id, String? title, String? body,
      NotificationDetails notificationDetail) {
    List payload = [id];

    return flutterLocalNotificationsPlugin.show(
      id.hashCode,
      title,
      body,
      notificationDetail,
      payload: jsonEncode(payload),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _handleDataRemoteMessage(RemoteMessage message) async {
    Map<String, dynamic> data = message.data;

    if (data.isEmpty) return;

    if (!Defaultdata.allowsNotification) return;

    if (Platform.isIOS && data['badge'] != null) {
      int badgeCount = int.parse(data['badge']);
      if (badgeCount == 0) {
        FlutterAppBadger.removeBadge();
      } else {
        FlutterAppBadger.updateBadgeCount(1);
      }
    }

    if (data['id'] == null) return;

    return _showMessage(data['id'], data['title'], data['content']);
  }
}
