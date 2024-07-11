import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  Function? onNotificationTap;

  NotificationService({this.onNotificationTap}) {
    tz.initializeTimeZones();
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null && onNotificationTap != null) {
          onNotificationTap!();
        }
      },
    );
  }

  Future<void> showWakeUpNotification() async {
    WidgetsBinding.instance?.addPostFrameCallback;
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'wake_up_channel1',
      'Wake Up Notifications',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarma'),
      importance: Importance.max,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Trezirea!',
      'A venit timpul sa te trezesti!',
      platformChannelSpecifics,
      payload: 'Trezire Payload',
    );
  }
}
