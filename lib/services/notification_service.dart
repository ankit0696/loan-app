import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loan_app/models/loan.dart';
import 'package:loan_app/models/notification.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("title: ${message.notification?.title}");
  print("body: ${message.notification?.body}");
}

class NotificationService {
   final _firebaseMessaging = FirebaseMessaging.instance;

   final _android = const AndroidNotificationDetails(
    'loan_app',
    'Loan App',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    channelDescription: 'Loan App', 
  );
   
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('app_logo');

  var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  // get notification permission
  Future<void> getNotificationPermission() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool permissionAsked =
        prefs.getBool('notification_permission_asked') ?? false;
    // ask only once for permission
    if (permissionAsked == false) {
      // use permission handler to get permission
      try {
        PermissionStatus status = await Permission.notification.status;
        if (status.isGranted) {
          print('Notification permission granted');
        } else {
          print('Notification permission denied');
          Permission.notification.request();
        }
      } catch (e) {
        print(e);
      }

      // save permission asked
      prefs.setBool('notification_permission_asked', true);
    }
  }

  // initilize notification
  Future<void> initialise() async {
    await _firebaseMessaging.requestPermission();
    String? fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fcmToken");

     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _android.channelId,
            _android.channelName,
            channelDescription: _android.channelDescription,
            icon: 'app_logo',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
    initializeNotification();
  }

  // initialize notification
  void initializeNotification() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(android: _androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  // send notification
  Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    // get notification id from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int notificationId = prefs.getInt('notification_id') ?? -1;

    if (notificationId == -1) {
      // get count from firebase and set notification id
    }

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      await notificationDetails(),
    );
  }

  // schedule notification
  Future scheduleNotification(
    int id, {
    String? title,
    String? body,
    required DateTime scheduledDate,
  }) async {
    tz.TZDateTime scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

    return flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      await notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future predocallySetNotification(
    int id, {
    String? title,
    String? body,
    String? payLoad,
  }) async {
    print("yess");
    return flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.daily,
      await notificationDetails(),
    );
  }

  Future<void> scheduleMonthlyRepeatingNotification({
    String? title,
    String? body,
    required DateTime initialScheduledDate,
    required NotificationModel notificationModel,
    required LoanModel data,
  }) async {
    // Calculate the initial time for the first notification on the first day of the month at 10 AM
    var initialTime = DateTime(
      initialScheduledDate.year,
      initialScheduledDate.month,
      initialScheduledDate.day, // Set the day to 1 (first day of the month)
      10, // Set the hour to 10 (10 AM)
      0, // Set the minute to 0 (on the hour)
    );

    int notificationCount = await FirestoreService().countNotification();

    for (int i = 0; i < 12; i++) {
      print("yes $initialTime");

      notificationModel.notificationId = notificationCount + 1;
      await FirestoreService().addNotification(
        notificationModel,
        data,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationCount.hashCode,
        title! + initialTime.toIso8601String(),
        body,
        tz.TZDateTime.from(initialTime, tz.local),
        await notificationDetails(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      notificationCount++;                                

      // Calculate the time for the next month (1 month later), considering year change
      int nextMonth = initialTime.month + 1;
      int nextYear = initialTime.year;

      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }

      initialTime = DateTime(
        nextYear,
        nextMonth,
        initialScheduledDate.day, // Set the day to 1 (first day of the month)
        10, // Set the hour to 10 (10 AM)
        0, // Set the minute to 0 (on the hour)
      );

      print("yes $notificationCount");
    }

    print("Test ing");
  }

  // Cancel a specific notification by ID
  Future<void> cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}
